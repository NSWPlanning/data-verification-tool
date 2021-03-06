class LocalGovernmentAreaRecord < ActiveRecord::Base

  serialize :error_details, ActiveRecord::Coders::Hstore
  after_initialize :init

  def init
    # otherwise we save nil, which violates DB constraints.
    self.error_details = {} if self.error_details.nil? 
  end

  include PgSearch
  pg_search_scope :search_by_address, :against => [
    :ad_unit_no,
    :ad_st_no_from,
    :ad_st_no_to,
    :ad_st_name,
    :ad_st_type,
    :ad_st_type_suffix,
    :ad_postcode,
    :ad_suburb,
    :ad_lga_name
  ]

  include RecordSearchHelper
  include DVT::PlanLabelInstanceMethods

  belongs_to :land_and_property_information_record
  belongs_to :local_government_area

  def self.raw_attributes
    [
      :date_of_update,
      :council_id,
      :if_partial_lot,
      :dp_lot_number,
      :dp_section_number,
      :dp_plan_number,
      :ad_unit_no,
      :ad_st_no_from,
      :ad_st_no_to,
      :ad_st_name,
      :ad_st_type,
      :ad_st_type_suffix,
      :ad_postcode,
      :ad_suburb,
      :ad_lga_name,
      :land_area,
      :frontage,
      :lep_nsi_zone,
      :lep_si_zone,
      :if_critical_habitat,
      :if_wilderness,
      :if_heritage_item,
      :if_heritage_conservation_area,
      :if_heritage_conservation_area_draft,
      :if_coastal_water,
      :if_coastal_lake,
      :if_sepp14_with_100m_buffer,
      :if_sepp26_with_100m_buffer,
      :if_aquatic_reserve_with_100m_buffer,
      :if_wet_land_with_100m_buffer,
      :if_aboriginal_significance,
      :if_biodiversity_significance,
      :if_land_reserved_national_park,
      :if_land_reserved_flora_fauna_geo,
      :if_land_reserved_public_purpose,
      :if_unsewered_land,
      :if_acid_sulfate_soil,
      :if_fire_prone_area,
      :if_flood_control_lot,
      :ex_buffer_area,
      :ex_coastal_erosion_hazard,
      :ex_ecological_sensitive_area,
      :ex_protected_area,
      :if_foreshore_area,
      :ex_environmentally_sensitive_land,
      :if_anef25,
      :transaction,
      :if_western_sydney_parkland,
      :if_river_front,
      :if_land_biobanking,
      :if_sydney_water_special_area,
      :if_sepp_alpine_resorts,
      :if_siding_springs_18km_buffer,
      :acid_sulfate_soil_class,
      :if_mine_subsidence,
      :if_local_heritage_item,
      :if_orana_rep
    ]
  end

  def self.functional_attributes
    [
      :transaction_type,
      :md5sum,
      :land_and_property_information_record_id,
      :local_government_area_id,
      :error_details
    ]
  end

  attr_accessible *(LocalGovernmentAreaRecord.functional_attributes | LocalGovernmentAreaRecord.raw_attributes)

  validates_presence_of :date_of_update,
    :council_id,
    :dp_plan_number,
    :ad_st_name,
    :ad_postcode,
    :ad_suburb,
    :ad_lga_name,
    :md5sum

  validates_presence_of :lep_si_zone, :unless => :has_si_mapping?

  # TODO: Metadata.
  # ===========================================================================
  # Custom validator that checks required attributes against the metadata form.
  # if_critical_habitat,
  # if_wilderness,
  # if_heritage_item,
  # if_heritage_conservation_area,
  # if_heritage_conservation_area_draft,
  # if_coastal_water,
  # if_coastal_lake,
  # if_sepp14_with_100m_buffer,
  # if_sepp26_with_100m_buffer,
  # if_aquatic_reserve_with_100m_buffer,
  # if_wet_land_with_100m_buffer,
  # if_aboriginal_significance,
  # if_biodiversity_significance,
  # if_land_reserved_national_park,
  # if_land_reserved_flora_fauna_geo,
  # if_land_reserved_public_purpose,
  # if_unsewered_land,
  # if_acid_sulfate_soil,
  # if_fire_prone_area,
  # if_flood_control_lot,
  # ex_buffer_area,
  # ex_coastal_erosion_hazard,
  # ex_ecological_sensitive_area,
  # ex_protected_area,
  # if_foreshore_area,
  # ex_environmentally_sensitive_land,
  # if_anef25,
  # transaction_type,
  # if_western_sydney_parkland,
  # if_river_front,
  # if_land_biobanking,
  # if_sydney_water_special_area,
  # if_sepp_alpine_resorts,
  # if_siding_springs_18km_buffer,
  # acid_sulfate_soil_class,
  # if_mine_subsidence,
  # if_local_heritage_item,
  # if_orana_rep,

  validates_presence_of :land_and_property_information_record_id,
    :message => 'cannot be found for this record'

  validates_format_of :dp_plan_number, :with => /^(DP|SP)[0-9]+$/,
    :message => 'must begin with either DP or SP and be followed only by numbers'

  validates_exclusion_of :ad_st_no_from, :in => ['0'],
    :message => 'must not be "0"'

  validates_exclusion_of :ad_st_no_to, :in => ['0'],
    :message => 'must not be "0"'

  validate :dp_lot_number_is_not_null_for_dp_lots

  scope :valid,   where(:is_valid => true)
  scope :invalid, where(:is_valid => false)

  scope :dp,  where("dp_plan_number LIKE 'DP%'")
  scope :sp,  where("dp_plan_number LIKE 'SP%'")
  scope :not_sp_or_dp,
    where("dp_plan_number IS NULL OR (dp_plan_number NOT LIKE 'SP%' AND dp_plan_number NOT LIKE 'DP%')")

  scope :in_lpi, where('land_and_property_information_record_id IS NOT NULL')
  scope :not_in_lpi, where('land_and_property_information_record_id IS NULL')

  def dp_lot_number_is_not_null_for_dp_lots
    # only SP lots are allowed to have an empty/nil dp_lot_number
    #  dp_plan_number.nil? guard is ok because absence of plan_number is picked up
    #  by other validators.
    if !dp_plan_number.nil? && dp_lot_number.blank? && dp_plan_number[0,2].eql?('DP')
      errors.add(:dp_lot_number, "lot number cannot be blank for DP land parcels")
    end
  end

  def self.inconsistent_attributes_comparison_fields
    # all land-based exclusions, plus SI zone
    attribute_names.select {|n| n.match(/^(ex_|if_|lep_si_zone)/) }
  end

  def inconsistent_attributes_comparison_fields
    # all land-based exclusions, plus SI zone
    attributes.select { |k, v| k.match(/^(ex_|if_|lep_si_zone)/) }
  end

  def sp_attributes_that_differ_from(other)
    inconsistent_attributes_comparison_fields.diff(
      other.inconsistent_attributes_comparison_fields
    )
  end

  def sp_attributes_that_differ_from_neighbours
    {}.tap do |diff|
      sp_common_plot_neighbours.each do |neighbour|
        diff.merge! sp_attributes_that_differ_from(neighbour)
      end
    end
  end

  def title_reference
    [dp_lot_number,dp_section_number,dp_plan_number].join('/')
  end

  def valid?(context = nil)    
    valid_record = super context

    # We use error_details to persist error info to the DB, as 
    #  re-running validation logic on load is extremely expensive.
    # Copy errors to error_details so:
    # 1- error checks like 'has_invalid_title_reference?' return the 
    #   correct values pre-save-to-database
    # 2- error details are saved to the database
    #
    # Note that activerecord-postgres-hstore will read the keys back 
    #  out as strings instead of symbols. Hence, we convert them to 
    #  keep functionality the same. 
    # Rails also sets ad_postcode => ["can't be blank"] (ie, value as
    #  an array). This gets turned into a string by the gem when saving
    #  to the DB, so we need to to_sentence any arrays that exist in the values
    write_attribute(:is_valid, valid_record)
    details = Hash[errors.messages].stringify_keys
    details.each { |k,v| details[k] = v.to_sentence if v.respond_to?(:to_sentence) }
    write_attribute(:error_details, details)

    valid_record
  end

  def has_address_errors?
    !is_valid && (LocalGovernmentAreaRecord.address_attributes & error_details.keys).length > 0
  end

  def address_errors
    error_details.select {|k,v| k =~ /^ad_/}
  end

  def self.address_attributes
    attribute_names.select{|a| a =~ /^ad_/}
  end

  def missing_si_zone?
    !is_valid && !error_details["lep_si_zone"].nil?
  end

  def has_invalid_title_reference?
    !is_valid && (LocalGovernmentAreaRecord.invalid_title_reference_attributes & error_details.keys).length > 0
  end

  def self.invalid_title_reference_attributes
    ["dp_plan_number","dp_lot_number"]
  end

  def to_s
    title_reference
  end

  def is_sp_property?
    self.dp_plan_number.starts_with? "SP"
  end

  def sp_common_plot_neighbours
    if is_sp_property?
      LocalGovernmentAreaRecord.where(
        "dp_plan_number = ? AND dp_lot_number <> ?",
        self.dp_plan_number, self.dp_lot_number).all
    else
      []
    end
  end

  def number_of_sp_common_plot_neighbours
    if is_sp_property?
      LocalGovernmentAreaRecord.where(
        "dp_plan_number = ? AND dp_lot_number <> ?",
        self.dp_plan_number, self.dp_lot_number).count
    else
      0
    end
  end

  def self.search(filter, conditions = {})
    super(filter, conditions, :dp_plan_number, :dp_section_number, :dp_lot_number)
  end

  def land_parcel
    @land_parcel ||= LandParcelRecord.new(title_reference)
  end

  def raw_record
    attributes.select { |k, v| LocalGovernmentAreaRecord.raw_attributes.include? k.to_sym }
  end

  def zone_mappings(options = {})
    @zone_mappings ||= NonStandardInstrumentationZone.where(options.merge!({
      :council_id => self.council_id,
      :local_government_area_id => self.local_government_area
    }))
  end

  def has_si_mapping?
    zone_mappings.count > 0
  end

  def lep_si_zone
    zone_mapping_attribute(:lep_si_zone)
  end

  def lep_si_zone=(value)
    write_attribute(:lep_si_zone, value)
  end

  def lep_nsi_zone
    zone_mapping_attribute(:lep_nsi_zone)
  end

  def lep_nsi_zone=(value)
    write_attribute(:lep_nsi_zone, value)
  end

  private

  def zone_mapping_attribute(name, options = {})
    zones = zone_mappings.collect(&name).compact.join("; ")
    if zones.blank?
      zones = read_attribute(name)
    end
    zones
  end

end
