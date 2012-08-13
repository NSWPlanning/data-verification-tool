namespace :lpi do
  desc 'Import an LPI CSV file, attributing the import to the given user'
  task :import, [:file, :user_email] => [:environment] do |t, args|
    user = User.find_by_email!(args[:user_email])
    importer = LandAndPropertyInformationImporter.new(args[:file], user)
    importer.import
    importer.exceptions.each {|e| puts e}
    puts "Processed %d, created %d, updated %d, errors %d" % [
      importer.processed, importer.created, importer.updated, importer.errors
    ]
  end
end
