class LocalGovernmentAreasController < AdminController

  # Skipping this filter does not mean *any* user can view the resource.
  # Access is still controlled by the find_model method, which won't allow
  # users who don't have access to this LGA.
  skip_before_filter :require_admin!,
    :only => [
      :index,
      :show,
      :uploads,
      :nsi_zone_uploads,
      :detail,
      :error_records,
      :import,
      :nsi_zone_import,
      :only_in_council,
      :only_in_lpi
    ]

  # Allows API access to certain methods - skips here should be paired with
  # calls in allow_api_access
  def api_actions
    [:import, :only_in_council, :only_in_lpi, :error_records]
  end

  # Setup breadcrumbs
  add_breadcrumb 'All Councils', '', :only => [:index]

  include ResourceController

  def uploads
    data_file = params[:data_file]
    zoneFile = data_file.original_filename.downcase.include?("_lep")
    
    # find LGA id
    if (!params[:id].nil?)      
      # local_government_area/:id/import
      lga_id = params[:id]
    else
      # local_government_area/import
      if (zoneFile)
        filename_lga_name, date_string = DVT::NSI::DataFile.parse_filename(params[:data_file].original_filename)
      else
        filename_lga_name, date_string = DVT::LGA::DataFile.parse_filename(params[:data_file].original_filename)
      end
      lga_id = lookup_alias(filename_lga_name)
    end
    @local_government_area = find_model(lga_id)
    

    # Assume that we're using the lga importer.
    if(zoneFile)
      NonStandardInstrumentationZoneImporter.enqueue(@local_government_area, params[:data_file], current_user)
    else
      LocalGovernmentAreaRecordImporter.enqueue(@local_government_area, params[:data_file], current_user)
    end

    respond_to do |format|
      format.html {
        redirect_to @local_government_area, :notice => 'Your data file will be processed shortly.'
      }
      format.json {
        render :nothing =>true, :status => :ok
      }
    end

  rescue DVT::Base::DataFile::InvalidFilenameError => file_error
    render text: file_error.to_s, status: 403
  rescue LocalGovernmentAreaLookup::AliasNotFoundError => lga_not_found_error
    render text: lga_not_found_error, status: 404
  end

  # The /import actions are exactly the same as the /uploads actions, except
  # they pass through different sets of before filters.
  alias :import :uploads

  def error_records
    @local_government_area = find_model(params[:id])
    @title = "Error records for #{@local_government_area.name}"
    add_council_and_import_breadcrumbs
    add_breadcrumb "Errors", ''
  end

  def only_in_council
    @local_government_area = find_model(params[:id])
    add_council_and_import_breadcrumbs
    add_breadcrumb "Only In Council", ''
    @source_field_name = 'Council ID'
    @source_field_id = 'council_id'
  end

  def only_in_lpi
    @local_government_area = find_model(params[:id])
    add_council_and_import_breadcrumbs
    add_breadcrumb "Only In LPI", ''
    @source_field_name = 'CADID'
    @source_field_id = 'cadastre_id'
  end

  protected

  def human_singular_name
    "Council"
  end

  def add_council_and_import_breadcrumbs
    add_breadcrumb "#{@local_government_area.name}", 'local_government_area_path(@local_government_area.id)'
    # Import date breadcrumb
    lga = @local_government_area
    add_breadcrumb lga.most_recent_import_date.strftime("%-d %b %y"),
                   local_government_area_detail_path(lga.id, lga.most_recent)
  end

  def format_json?
    request.format.json?
  end

  def lookup_alias(filename_lga_name)
    return LocalGovernmentAreaLookup.new.find_id_from_filename_alias(filename_lga_name)
  end
end
