class LandAndPropertyInformationImporter

  attr_reader :filename, :user, :processed, :created, :updated, :errors,
              :exceptions

  delegate :has_record?, :find_if_changed, :seen?, :seen!, :mark_as_seen,
    :to => :lpi_lookup
  delegate :transaction, :create!, :to => :target_class

  def initialize(filename, user)
    @filename     = filename
    @user         = user
    zero_counters
  end

  def zero_counters
    @exceptions = []
    @processed = @created = @updated = @errors = 0
  end

  def import(batch_size = 1000)
    logger.info "Beginning LPI import of '#{filename}' for #{user} (#{user.id})"
    begin
      LPI::DataFile.new(filename).each_slice(batch_size) do |batch|
        transaction do
          process_batch(batch)
        end
      end
      logger.info "LPI import of '%s' complete (processed: %d, created: %d, updated: %d, errors: %d)" % [
        filename, processed, created, updated, errors
      ]
      ImportMailer.import_complete(self)
    rescue
      ImportMailer.import_failed(self, $!)
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
      rescue  LandAndPropertyInformationLookup::RecordAlreadySeenError,
              LocalGovernmentAreaLookup::AliasNotFoundError => e
        logger.error "Caught import error: #{e}"
        @exceptions.push(e)
        @errors += 1
      end
    end
  end

  def update_record_if_changed(record)

    if lpi = find_if_changed(record)
      lpi.update_attributes(record_attributes(record))
      @updated += 1
      lpi
    end

  end

  # Creates a LandAndPropertyInformation record in the database from an
  # LPI::Record
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

  def target_class
    LandAndPropertyInformationRecord
  end

  protected
  def logger
    Rails.logger
  end

  protected
  def record_attributes(record)
    record.to_hash.merge(
      :local_government_area_id => lga_lookup.find_id_from_alias(record.lga_name)
    )
  end

end
