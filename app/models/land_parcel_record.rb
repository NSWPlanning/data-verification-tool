class LandParcelRecord

  class RecordNotFound < StandardError
    attr_accessor :title_reference

    def initalize(title_reference)
      @title_reference = title_reference
      super "Unable to find land parcel with title reference #{@title_reference}"
    end
  end

  attr_accessor :lpi_record, :lga_record, :lga_records, :title_reference

  def initialize(title_reference, options={})
    @parsed_title_reference = parse_title_reference(title_reference)
    @title_reference = @parsed_title_reference.values.reverse.join("/")
    @errors = {}
    records options
  end

  def records(options = {})
    if options.has_key?(:skip_load) && options[:skip_load] == true
      @records = {
        :lpi_record => options[:lpi_record],
        :lga_record => options[:lga_record],
        :lga_records => options[:lga_records]
      }
    else
      @records ||= find_records(@parsed_title_reference)
    end

    @lpi_record = @records[:lpi_record]
    @lga_records = @records[:lga_records]
    @lga_record = @records[:lga_record]

    if @lpi_record.blank? && @lga_record.blank? && @lga_records.blank?
      raise RecordNotFound.new(@title_reference)
    end
  end

  def in_lpi?
    !@lpi_record.blank?
  end

  def in_lga?
    !@lga_record.blank? || !@lga_records.blank?
  end

  def is_sp?
    @title_reference.include? "/SP"
  end

  def common_property?
    @title_reference.starts_with? "//SP"
  end

  def is_valid
    !@lga_records.collect(&:is_valid).include? false
  end

  def valid?
    @errors = nil
    errors.blank? && attribute_error_information.blank?
  end

  def errors
    if @errors.nil?
      @errors = {}
      in_multiple_lgas?
      duplicate_dp?
      only_in_lpi?
      retired_lpi?
      valid_attributes?
      inconsistent_attributes?

      strip_duplicates!
    end
    @errors
  end

  # Creates a hash of each of the error keys, to their message for all of the
  # records that make up the land parcel.
  def attribute_error_information
    @attribute_error_information ||= {}.tap do |errors|
      [@lga_record, @lga_records].flatten.compact.each do |record|
        unless record.valid?
          errors.merge! Hash[record.errors.messages.map { |k, v|
            [k, [k.to_s, v.collect(&:humanize)].join(" ")]
          }]
        end
      end
    end
  end

  def inconsistent_attribute_information
    @inconsistent_attributes ||= {}.tap do |attrs|
      if is_sp? && !@lga_records.blank?
        attrs.merge! @lga_record.sp_attributes_that_differ_from_neighbours
      end
    end
  end

  def address_information
    @address_information ||= clean_information({}.tap { |info|
      unless @lga_record.nil?
        info[:title_reference] = @lga_record.title_reference
        info[:street_address] = record_street_address(@lga_record)
        info[:council] = @lga_record.ad_lga_name
      end
    })
  end

  def land_information
    @land_information ||= {}.tap do |information|
      unless @lga_record.blank?

        information.merge! clean_information({}.tap { |information|
          information[:lep_si_zone] = @lga_record.lep_si_zone

          information[:lep_nsi_zone] = @lga_record.lep_nsi_zone

          unless @lga_record.land_area.to_f == 0.0
            information[:area] = @lga_record.land_area.to_f.round(1).to_s
          end

          unless @lga_record.frontage.to_f == 0.0
            information[:frontage] = @lga_record.frontage.to_f.round(1).to_s
          end
        })

        information.merge! clean_information_unless({
          :heritage_status => @lga_record.if_heritage_item
        }, "Heritage Item")

        information.merge! clean_information_unless({
          :acid_sulfate_soil_class => @lga_record.acid_sulfate_soil_class
        }, "1", "2", "3", "4", "5", "Yes")

        # Items begining with IF or EX
        attributes = @lga_record.attributes
        information.merge! clean_information_unless(attributes.select { |k, v|
          k.match(/^(ex_|if_)/)
        }, 'Yes')
      end
    end
  end

  def record_information
    @record_information ||= clean_information({}.tap { |info|
      unless @lga_record.nil?
        info[:council_file_date_of_update] = record_date(@lga_record.date_of_update)
        info[:council_id] = @lga_record.council_id
        unless lga_record.dp_plan_number.blank? || !lga_record.is_sp_property?
          info[:common_strata_plan] = "//#{lga_record.dp_plan_number}"
        end
        info[:lots_in_strata_plan] = @lga_record.sp_common_plot_neighbours
      end

      unless @lpi_record.nil?
        info[:cadid] = @lpi_record.cadastre_id
        info[:lpi_last_updated] = record_date(@lpi_record.last_update)
        info[:lpi_retired] = @lpi_record.retired
      end
    })
  end

  def production_information
    clean_information({
      :attribute_value => nil,
      :status_updated => nil,
      :valid_in_production => nil,
      :exempt_development_permitted => nil,
      :complying_development_permitted => nil
    })
  end

  def raw_record_information
    unless @lga_record.blank?
      @raw_record_information ||= @lga_record.raw_record
    else
      {}
    end
  end

  def local_government_areas
    @local_government_areas ||= load_local_government_areas
  end

  def duplicate_dp?
    if (@lga_records.count > 1) && (!is_sp? && !common_property?)

      range = Set.new(@lga_records.collect(&:title_reference))
      if range.length == 1
        @errors[:duplicate_dp] = "This title reference occurs #{@lga_records.length} times in the Council file. This land parcel is not available in the EHC."
        return true
      end
    end
    false
  end

  def in_multiple_lgas?
    if local_government_areas.count > 1
      @errors[:in_more_than_one_lga] = "This land parcel spans multiple Council areas. It is not available in the EHC."
      true
    else
      false
    end
  end

  def retired_lpi?
    if in_lpi? && @lpi_record.retired == true
      @errors[:lpi_retired] = "This land parcel is retired in the LPI. It is not available in the EHC."
      true
    else
      false
    end
  end

  def only_in_lpi?
    if !in_lpi? && in_lga?
      if common_property?
        @errors[:only_in_council_sp_common_property] = "This strata plan does not exist in LPI. The lots are not available in the EHC."
      elsif is_sp?
        @errors[:only_in_council_sp] = "This strata plan does not exist in LPI. This lot is not available in the EHC."
      else
        @errors[:only_in_council] = "This land parcel does not exist in LPI in this Council area. It is not available in the EHC."
      end
      true
    elsif in_lpi? && !in_lga?
      @errors[:only_in_lpi] = "This land parcel does not exist in any Council file. It is not available in the EHC."
      true
    else
      false
    end
  end

  def valid_attributes?
    unless common_property?
      if attribute_error_information.keys.length == 1
        @errors[:invalid_with_one_error] = "This land parcel has an error and is not available in the EHC."
      elsif attribute_error_information.keys.length > 1
        @errors[:invalid_with_multiple_errors] = "This land parcel has errors and is not available in the EHC."
      end
      false
    else
      true
    end
  end

  def inconsistent_attributes?
    unless inconsistent_attribute_information.blank?
      if common_property?
        @errors[:inconsistent_attributes_sp_common] = "Lots in this strata plan have inconsistent land-based information. The lots are not available in the EHC."
      else
        @errors[:inconsistent_attributes_sp] = "This strata lot has land-based information that is inconsistent with other lots in the strata plan. It is not available in the EHC."
      end
      true
    else
      false
    end
  end

  def self.search(filter, options ={})
    lpi_records = LandAndPropertyInformationRecord.search(filter, options).all.map { |r|
      r.title_reference
    }

    lga_records = LocalGovernmentAreaRecord.search(filter, options).all.map { |r|
      r.title_reference
    }

    (lpi_records | lga_records).map do |title_reference|
      LandParcelRecord.new(title_reference)
    end
  end

  def self.search_by_address(address, options={})
    address = address.gsub(/\/|-|,/, ' ').gsub(/\s{2,}/, ' ')
    pagination = {}
    pagination = {
      :page => 1,
      :per_page => 200
    }.merge!(options.delete(:paginate)) if options.has_key? :paginate

    lga_records = LocalGovernmentAreaRecord.where(options).search_by_address(address)

    if pagination.blank?
      lga_records.all.map do |record|
        LandParcelRecord.new(record.title_reference,
          :skip_load => true,
          :lga_records => [record],
          :lga_record => record)
      end
    else
      {}.tap do |result|
        records = lga_records.paginate(pagination)
        result[:land_parcels] = records.map { |record|
          LandParcelRecord.new(record.title_reference,
            :skip_load => true,
            :lga_records => [record],
            :lga_record => record)
        }
        result[:pagination] = {}.tap { |pagination|
          [
            :previous_page,
            :next_page,
            :current_page,
            :per_page,
            :total_entries,
            :total_pages
          ].each { |i| pagination[i] = records.send(i) }
        }
      end
    end
  end

  protected

  def load_local_government_areas
    ids = []
    unless @lga_records.blank?
      ids.push @lga_records.collect(&:local_government_area_id)
    end

    unless @lpi_record.blank?
      ids.push @lpi_record.local_government_area_id
    end
    LocalGovernmentArea.where(:id => ids)
  end

  def strip_duplicates!
    unless (@errors.keys & [:only_in_council_sp_common_property,
      :only_in_council_sp, :only_in_council]).length == 0
      attribute_error_information.delete :land_and_property_information_record_id
    end
  end

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
      clean_information({}.tap { |address|
        street = []
        unless record.ad_unit_no.blank?
          street.push record.ad_unit_no, "/"
        end

        unless record.ad_st_no_from.blank?
          street.push record.ad_st_no_from
        end

        unless record.ad_st_no_to.blank?
          street.push "-", record.ad_st_no_to
        end

        street = [street.join("")]
        [:ad_st_name, :ad_st_type, :ad_st_type_suffix].each do |a|
          value = record.send(a)
          street.push value unless value.blank?
        end

        unless street.blank?
          address[:street] = street.join(" ")
        end

        unless record.ad_suburb.blank?
          address[:suburb] = record.ad_suburb
        end

        unless record.ad_postcode.blank?
          address[:state] = "NSW #{record.ad_postcode}"
        else
          address[:state] = "NSW"
        end
      })
    end
  end

  #
  # Attempt to find the LPI record
  # Attempt to find the LGA record
  #
  # If the title reference is for one SP then find all of the plots.
  # If the title is for a specific SP plot the find it.
  # If the title is for a DP find its LPI instance.
  # if the title for for a DP find its LGA instance.
  #
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
        records[:lga_records] = LocalGovernmentAreaRecord.where(filter).all
      end
      records[:lga_record] = records[:lga_records].first
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
