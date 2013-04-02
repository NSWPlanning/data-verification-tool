class ImportMailer < ActionMailer::Base

  default :from => Rails.application.config.default_mail_from

  @host_name = ActionMailer::Base.default_url_options[:host]

  def import_complete(importer)
    @importer = importer
    @exceptions = importer.exceptions
    @user = importer.user

    mail :to => @user.email, :subject => "Import complete"
  end

  def import_failed(importer, exception)
    @importer = importer
    @exception = exception
    @user = importer.user

    mail :to => @user.email, :subject => 'Import failed'
  end

  def complete(importer)
    assign_lga_information importer

    mail :to => @user.email, :subject => "#{@local_government_area.name} Import complete"
  end

  def empty(importer, exception)
    assign_lga_information importer, exception

    mail :to => @user.email, :subject => '#{@local_government_area.name} Import failed'
  end

  def filename_incorrect(importer, exception)
    assign_lga_information importer, exception

    mail :to => @user.email, :subject => "#{@local_government_area.name} Import failed"
  end

  def header_errors(importer, exception)
    assign_lga_information importer, exception

    mail :to => @user.email, :subject => "#{@local_government_area.name} Import failed"
  end

  def unparseable(importer, exception)
    assign_lga_information importer, exception

    mail :to => @user.email, :subject => "#{@local_government_area.name} Import failed"
  end

  def aborted(importer, exception)
    assign_lga_information importer, exception

    mail :to => @user.email, :subject => "#{@local_government_area.name} Import failed"
  end

  protected

  def assign_lga_information(importer, exception=nil)
    @importer = importer
    @filename = importer.filename.to_s.split("/").last
    @exception = exception
    @exceptions = importer.exceptions
    @user = importer.user
    @local_government_area = @importer.local_government_area
    @import_log = @local_government_area.
      local_government_area_record_import_logs.
      successful.first
    @host_name = ActionMailer::Base.default_url_options[:host]
  end

end
