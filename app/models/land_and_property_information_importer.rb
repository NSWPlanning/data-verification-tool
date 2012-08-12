class LandAndPropertyInformationImporter

  attr_reader :filename, :user, :processed, :created, :updated, :errors

  delegate :has_record?, :find_if_changed, :seen?, :mark_as_seen, :to => :lookup
  delegate :transaction, :create!, :to => :target_class

  def initialize(filename, user)
    @filename     = filename
    @user         = user
    zero_counters
  end

  def zero_counters
    @processed = @created = @updated = @errors = 0
  end

  def import(batch_size = 1000)
    LPI::DataFile.new(filename).each_slice(batch_size) do |batch|
      transaction do
        process_batch(batch)
      end
    end
  end

  def process_batch(batch)
    batch.each do |record|

      @processed += 1
      if seen?(record)
        @errors += 1
        next
      end

      unless has_record?(record)
        mark_as_seen(create!(record.to_hash))
        @created += 1
      else
        if lpi = update_record_if_changed(record)
          mark_as_seen(lpi)
        end
      end
    end
  end

  def update_record_if_changed(record)

    if lpi = find_if_changed(record)
      lpi.update_attributes(record.to_hash)
      @updated += 1
      lpi
    end

  end

  def lookup
    @lookup ||= LandAndPropertyInformationLookup.new(target_class)
  end

  def add_to_lookup(lpi)
    lookup.add(lpi)
  end

  def target_class
    LandAndPropertyInformationRecord
  end

end
