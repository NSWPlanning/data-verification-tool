class LandParcelRecord

  attr_accessor :lpi_record, :lga_record, :lga_records

  class RecordNotFound < StandardError
    attr_accessor :title_reference

    def initalize(title_reference)
      @title_reference
      super "Unable to find land parcel with title reference #{@title_reference}"
    end
  end

  def initialize(title_reference)
    parsed_title_reference = parse_title_reference(title_reference)
    @title_reference = parsed_title_reference.values.reverse.join("/")
    records = find_records(parsed_title_reference)

    @lpi_record = records[:lpi_record]
    if !@lpi_record.blank? && common_property?
      @lga_records = records[:lga_records]
    else
      @lga_record = records[:lga_record]
    end

    if @lpi_record.nil? && @lga_record.nil? && @lga_records.nil?
      raise RecordNotFound.new(title_reference)
    end
  end

  def title_reference
    @title_reference
  end

  def in_lpi?
    !@lpi_record.blank?
  end

  def in_lga?
    !@lga_record.blank? || !@lga_records.blank?
  end

  def common_property?
    title_reference.starts_with? "//SP"
  end

  def has_errors?
    raise StandardError.new("Not yet implemented")
  end

  def error_information
    raise StandardError.new("Not yet implemented")
  end

  def address_information
    clean_information({}.tap { |info|
      unless @lga_record.nil?
        info[:title_reference] = @lga_record.title_reference
        info[:street_address] = record_street_address(@lga_record)
        info[:council] = @lga_record.ad_lga_name
      end
    })
  end

  def land_information
    clean_information({}.tap { |info|
      unless @lga_record.nil?
        info[:zone] = @lga_record.lep_si_zone
        info[:area] = @lga_record.land_area
        info[:frontage] = @lga_record.frontage
        info[:heritage_status] = @lga_record.if_heritage_item
        info[:acid_sulfate_soil_class] = @lga_record.acid_sulfate_soil_class
      end
    })
  end

  def record_information
    clean_information({}.tap { |info|
      unless @lga_record.nil?
        info[:council_file_date_of_update] = record_date(@lga_record.date_of_update)
        info[:council_id] = @lga_record.council_id
        info[:lots_in_strata_plan] = @lga_record.sp_common_plot_neighbours
      end

      unless @lpi_record.nil?
        info[:cadid] = @lpi_record.cadastre_id
        info[:lpi_last_updated] = record_date(@lpi_record.last_update)
      end
    })
  end

  def production_information
    raise StandardError.new("Not yet implemented")
    # clean_information({
    #   :attribute_value =>
    #   :status_updated =>
    #   :valid_in_production =>
    #   :exempt_development_permitted =>
    #   :complying_development_permitted =>
    # })`
  end

  protected

  def clean_information(hash = {})
    hash.reject { |k, v| v.blank? }
  end

  def record_date(date)
    date.to_date.strftime("%d/%m/%y")
  end

  def record_street_address(record)
    unless record.nil?
      record.address_attributes.map { |attr|
        record.send(attr)
      }.reject(&:blank?).join(" ")
    end
  end

  # Attempt to find the LPI record
  # Attempt to find the LGA record
  #
  # If the title reference is for one SP then find all of the plots.
  # If the title is for a specific SP plot the find it.
  # If the title is for a DP find its LPI instance.
  # if the title for for a DP find its LGA instance.

  def find_lpi_record(filter)
    if filter[:dp_plan_number].starts_with?( "SP")
      LandAndPropertyInformationRecord.where({
        :title_reference => "//#{filter[:dp_plan_number]}"
      }).first
    else
      LandAndPropertyInformationRecord.where({
        :title_reference => filter.values.reverse.join("/")
      }).first
    end
  end

  def find_records(filter)
    {}.tap do |records|
      if filter.values.compact.length == 1 && filter[:dp_plan_number].starts_with?( "SP")
        records[:lpi_record] = find_lpi_record(filter)
        records[:lga_records] = LocalGovernmentAreaRecord.where({
          :dp_plan_number => filter[:dp_plan_number]
        }).all
      else
        records[:lpi_record] = find_lpi_record(filter)
        records[:lga_record] = LocalGovernmentAreaRecord.where(filter).first
      end
    end
  end

  def parse_title_reference(title_reference)
    filters = title_reference.split("/").reject(&:blank?)
    unless 0 == filters.length
      filter = {
        :dp_plan_number => filters.pop,
        :dp_section_number => (filters.length > 1) ? filters.pop : nil,
        :dp_lot_number => (filters.length == 1) ? filters.pop : nil
      }
    else
      raise LandParcelRecordAmbiguity.new("Not enough information to find by land title")
    end
  end

end
