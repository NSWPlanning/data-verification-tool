class LandParcelRecord

  attr_accessor :lpi_record, :lga_record, :lga_records

  class RecordNotFound < StandardError
    attr_accessor :title_reference

    def initalize(title_reference)
      @title_reference = title_reference
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

  #
  # Land based information section contains everything in the CSV from SI Zone
  # onwards.
  #
  # --------------
  # Cleaning Fields
  # ---------------
  # NSI Zone unless blank
  # SI Zone
  # Frontage unless blank
  # Area unless blank

  # if_heritage_item unless missing, blank, 'NA' or 'Not a Heritage'
  # acid_sulfate_soil_class unless missing, blank, 'NA', or 'No'  (only valid
  # positive values are 'Yes', 1...5)
  #
  # All other attributes beginning with if_ or ex_
  # should equal 'Yes' to be displayed
  #
  # --------------
  # Display names:
  # --------------
  # if_heritage_item -> Heritage Item
  # if_ANEF25 -> ANEF25
  # ex_environmentally_sensitive_land -> Environmentally Sensitive Land.
  #
  def land_information
    {}.tap do |information|
      unless @lga_record.nil?

        information.merge! clean_information({
          :zone => @lga_record.lep_si_zone,
          :area => @lga_record.land_area,
          :frontage => @lga_record.frontage,
          :lep_nsi_zone => @lga_record.lep_nsi_zone,
        })

        information.merge! clean_information_unless({
          :heritage_status => @lga_record.if_heritage_item
        }, 'Heritage Item')

        information.merge! clean_information_unless({
          :acid_sulfate_soil_class => @lga_record.acid_sulfate_soil_class
        }, "1", "2", "3", "4", "5", "Yes")

        # Items begining with IF or EX
        information.merge! clean_information_unless({
          :critical_habitat => @lga_record.if_critical_habitat,
          :wilderness => @lga_record.if_wilderness,
          :heritage_item => @lga_record.if_heritage_item,
          :heritage_conservation_area => @lga_record.if_heritage_conservation_area,
          :heritage_conservation_area_draft => @lga_record.if_heritage_conservation_area_draft,
          :coastal_water => @lga_record.if_coastal_water,
          :coastal_lake => @lga_record.if_coastal_lake,
          :sepp14_with_100m_buffer => @lga_record.if_sepp14_with_100m_buffer,
          :sepp26_with_100m_buffer => @lga_record.if_sepp26_with_100m_buffer,
          :aquatic_reserve_with_100m_buffer => @lga_record.if_aquatic_reserve_with_100m_buffer,
          :wet_land_with_100m_buffer => @lga_record.if_wet_land_with_100m_buffer,
          :aboriginal_significance => @lga_record.if_aboriginal_significance,
          :biodiversity_significance => @lga_record.if_biodiversity_significance,
          :land_reserved_national_park => @lga_record.if_land_reserved_national_park,
          :land_reserved_flora_fauna_geo => @lga_record.if_land_reserved_flora_fauna_geo,
          :land_reserved_public_purpose => @lga_record.if_land_reserved_public_purpose,
          :unsewered_land => @lga_record.if_unsewered_land,
          :acid_sulfate_soil => @lga_record.if_acid_sulfate_soil,
          :fire_prone_area => @lga_record.if_fire_prone_area,
          :flood_control_lot => @lga_record.if_flood_control_lot,
          :foreshore_area => @lga_record.if_foreshore_area,
          :anef25 => @lga_record.if_anef25,
          :western_sydney_parkland => @lga_record.if_western_sydney_parkland,
          :river_front => @lga_record.if_river_front,
          :land_biobanking => @lga_record.if_land_biobanking,
          :sydney_water_special_area => @lga_record.if_sydney_water_special_area,
          :sepp_alpine_resorts => @lga_record.if_sepp_alpine_resorts,
          :siding_springs_18km_buffer => @lga_record.if_siding_springs_18km_buffer,
          :mine_subsidence => @lga_record.if_mine_subsidence,
          :local_heritage_item => @lga_record.if_local_heritage_item,
          :orana_rep => @lga_record.if_orana_rep,
          :ex_buffer_area => @lga_record.ex_buffer_area,
          :coastal_erosion_hazard => @lga_record.ex_coastal_erosion_hazard,
          :ecological_sensitive_area => @lga_record.ex_ecological_sensitive_area,
          :protected_area => @lga_record.ex_protected_area,
          :environmentally_sensitive_land => @lga_record.ex_environmentally_sensitive_land
        }, 'Yes')
      end
    end
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

  def clean_information_unless(hash = {}, *conditions)
    hash.reject { |k, v| !(conditions.include? v) }
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
