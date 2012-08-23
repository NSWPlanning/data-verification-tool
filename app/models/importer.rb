class Importer
  attr_reader :filename, :user, :processed, :created, :updated, :deleted,
              :error_count, :exceptions, :import_log, :import_run

  alias :import_run? :import_run

  delegate :has_record?, :find_if_changed, :seen?, :seen!, :mark_as_seen,
    :unseen_ids, :to => :lpi_lookup
  delegate :transaction, :create!, :to => :target_class

  class ImportNotRunError < StandardError ; end

  def initialize(filename, user)
    @filename     = filename
    @user         = user
    @import_run   = false
    zero_counters
  end

  def zero_counters
    @exceptions = []
    @processed = @created = @updated = @deleted = @error_count = 0
  end

  def import(batch_size = 1000)
    begin
      start_import
      data_file_class.new(filename).each_slice(batch_size) do |batch|
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

  def process_batch(batch)
    batch.each do |record|

      @processed += 1

      begin
        # Raise an exception if this record has already been seen in the
        # import.
        seen!(record)

        if has_record?(record)
          mark_as_seen(record)
          update_record_if_changed(record)
        else
          mark_as_seen(create_record!(record))
          @created += 1
        end
      rescue  *catchable_exceptions => e
        logger.error "Caught import error: #{e}"
        @exceptions.push(e)
        @error_count += 1
      end
    end
  end

  def update_record_if_changed(record)

    if ar_record = find_if_changed(record)
      ar_record.update_attributes(record_attributes(record))
      @updated += 1
      ar_record
    end

  end

  def create_record!(record)
    create!(record_attributes(record))
  end

  def lpi_lookup
    @lpi_lookup ||= LandAndPropertyInformationLookup.new(target_class)
  end

  def lga_lookup
    @lga_lookup ||= LocalGovernmentAreaLookup.new
  end

  def add_to_lookup(lpi)
    lpi_lookup.add(lpi)
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
    unseen.each do |record|
      record.destroy
      @deleted += 1
    end
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
    logger.info "Beginning import of '#{filename}' for #{user} (#{user.id})"
    @import_log = log_class.start! self
  end

  protected
  def complete_import
    logger.info "import of '%s' complete (processed: %d, created: %d, updated: %d, errors: %d)" % [
      filename, processed, created, updated, error_count
    ]
    import_log.complete!
    ImportMailer.import_complete(self).deliver
  end

  protected
  def fail_import(exception)
    import_log.fail!
    ImportMailer.import_failed(self, $!).deliver
  end

end
