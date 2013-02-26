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

  def lga_import_complete(importer)
    @importer = importer
    @exceptions = importer.exceptions
    @user = importer.user
    @local_government_area = @importer.local_government_area

    mail :to => @user.email, :subject => "#{@local_government_area.name} Import complete"
  end

end
