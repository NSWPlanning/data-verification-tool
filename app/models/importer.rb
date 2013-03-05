class Importer
  attr_reader :filename, :user, :processed, :created, :updated, :deleted,
              :error_count, :exceptions, :import_log, :import_run

  alias :import_run? :import_run

  delegate :has_record?, :find_if_changed, :seen?, :seen!, :mark_as_seen,
    :unseen_ids, :to => :primary_lookup
  delegate :transaction, :create!, :to => :target_class

  class ImportNotRunError < StandardError ; end

  def initialize(filename, user)
    @filename     = filename
    @user         = user
    @import_run   = false
    zero_counters
  end

  def zero_counters
    @exceptions = {}
    @processed = @created = @updated = @deleted = @error_count = 0
  end

  def import(batch_size = 1000)
    begin
      start_import
      @batch_count = 0
      data_file.each_slice(batch_size) do |batch|
        transaction do
          process_batch(batch)
        end
      end
      @import_run = true
      delete_unseen!
      complete_import
    rescue
      fail_import($!)
      raise $!
    end
  end

  # This can be overridden in the subclass to control whether records that
  # have already been seen in the CSV, i.e. effectively duplicate records,
  # will be saved.  The default is false, duplicate records are not saved
  # and the error is stored as an import exception.
  def store_seen_records?
    false
  end

  def process_batch(batch)
    @batch_count += 1
    batch.each do |record|
      @processed += 1
      begin
        # Raise an exception if this record has already been seen in the
        # import.
        seen = seen?(record)
        seen!(record) if seen && !store_seen_records?

        if has_record?(record)
          if seen
            create_record!(record)
          else
            mark_as_seen(record)
            update_record_if_changed(record)
          end
        else
          mark_as_seen(create_record!(record))
        end
      rescue *catchable_exceptions => e
        add_exception_for_record(e, record)
        increment_exception_counters(e)
        yield @processed, @batch_count if block_given?
      end
    end
  end

  def increment_exception_counters(exception)
  end

  def exception_counters
    @exception_counters ||= {}.tap {|h| h.default = 0}
  end

  def update_record_if_changed(record)

    if ar_record = find_if_changed(record)
      ar_record.update_attributes(record_attributes(record))
      @updated += 1
      ar_record
    end

  end

  def create_record!(record)
    r = create!(record_attributes(record))
    @created += 1
    return r
  end

  def lpi_lookup
    @lpi_lookup ||= LandAndPropertyInformationLookup.new(
      LandAndPropertyInformationRecord
    )
  end

  def lga_lookup
    @lga_lookup ||= LocalGovernmentAreaLookup.new
  end

  def lga_record_lookup
    @lga_record_lookup ||= LocalGovernmentAreaRecordLookup.new(
      LocalGovernmentAreaRecord
    ).tap do |lga_record_lookup|
      lga_record_lookup.local_government_area = local_government_area
    end
  end

  def sp_lpi_by_lga_lookup
    @sp_lpi_by_lga_lookup ||= SpLandAndPropertyInformationRecordByLocalGovernmentAreaLookup.new(
      LandAndPropertyInformationRecord
    ).tap do |sp_lpi_by_lga_lookup|
      sp_lpi_by_lga_lookup.local_government_area = local_government_area
    end
  end

  def dp_lpi_by_lga_lookup
    @dp_lpi_by_lga_lookup ||= DpLandAndPropertyInformationRecordByLocalGovernmentAreaLookup.new(
      LandAndPropertyInformationRecord
    ).tap do |dp_lpi_by_lga_lookup|
      dp_lpi_by_lga_lookup.local_government_area = local_government_area
    end
  end

  def add_to_lookup(lpi)
    self.send(:primary_lookup).add(lpi)
  end

  # Returns all the target_class instances that weren't seen during the import.
  # Will raise ImportNotRunError if #import has not yet been called.
  def unseen
    raise ImportNotRunError unless import_run?
    target_class.find(unseen_ids)
  end

  # Delete all the LandAndPropertyInformationRecord instances that were not seen
  # during the import.
  def delete_unseen!
    logger.info 'Deleting records not found in import file'
    unseen.each do |record|
      record.send(destroy_method)
      @deleted += 1
    end
  end

  def destroy_method
    :destroy
  end

  def catchable_exceptions
    []
  end

  def has_exception_on_line?(line)
    @exceptions.has_key?(line)
  end

  def base_exceptions
    @exceptions[:base] || []
  end

  # This is a noop by default, but can be overridden to perform actions once
  # the import has completed.  Is called on success and failure.
  def after_import
  end

  # This is a noop by default, but can be overridden to perform actions before
  # the import starts.
  def before_import
  end

  # Which fields to report in the statistics summary when sending the 'import
  # complete' email.
  def statistics_fields
    [:filename, :processed, :created, :updated, :deleted, :error_count]
  end

  def statistics
    Hash[statistics_fields.map { |s| [s, send(s)] }]
  end

  def new_data_file
    data_file_class.new(filename)
  end

  def data_file
    @data_file ||= new_data_file
  end

  protected
  def logger
    Rails.logger
  end

  protected
  def record_attributes(record)
    record.to_hash.merge(extra_record_attributes(record))
  end

  protected
  def extra_record_attributes(record)
    {}
  end

  protected
  def start_import
    @started_at = Time.now
    logger.info "Beginning import of '#{filename}' for #{user} (#{user.id})"
    @import_log = log_class.start! self
    dry_run
    before_import
  end

  # Because the CSV parser is streaming, it won't pick up any parse errors
  # on individual lines in the CSV until it hits them.  This means that
  # the processing run could fail half way through, with some of the records
  # imported and some not.
  #
  # To avoid this, we perform a dry run sweep across the whole file to ensure
  # that every line can be parsed.
  protected

  def valid_file_rows
    @valid_file_rows ||= 0
  end

  def dry_run
    new_data_file.each do |row|
      @valid_file_rows = valid_file_rows + 1
    end
  end

  protected
  def complete_import
    finish_import_with_state(:complete)
    ImportMailer.import_complete(self).deliver
  end

  protected
  def fail_import(exception)
    finish_import_with_state(:fail)
    ImportMailer.import_failed(self, $!).deliver
  end

  protected
  def finish_import_with_state(state)
    logger.info "import of '%s' %s (processed: %d, created: %d, updated: %d, errors: %d)" % [
      filename, state.to_s, processed, created, updated, error_count
    ]
    after_import
    import_log.send("#{state}!")
    log_duration
  end

  protected
  def log_duration
    logger.info "import duration %d seconds" % [Time.now - @started_at]
  end

  protected
  def add_exception_for_record(exception, record)
    logger.debug "Line: #{record.line}: Caught import error: #{exception}"
    @exceptions[record.line] = exception
    @error_count += 1
  end

  # Add an exception that isn't associated with a particular single record or
  # line number.
  protected
  def add_exception_to_base(exception)
    logger.debug "Adding base exception: #{exception}"
    @exceptions[:base] ||= []
    @exceptions[:base] << exception
    @error_count += 1
  end

end
