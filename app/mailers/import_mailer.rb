class ImportMailer < ActionMailer::Base
  default :from => Rails.application.config.default_mail_from

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
end