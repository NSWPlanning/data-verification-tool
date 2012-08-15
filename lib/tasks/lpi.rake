namespace :lpi do
  desc 'Import an LPI CSV file, attributing the import to the given user.'
  task :import, [:file, :user_email] => [:environment] do |t, args|
    user = User.find_by_email!(args[:user_email])
    importer = LandAndPropertyInformationImporter.new(args[:file], user)
    importer.import
    importer.exceptions.each {|e| puts e}
    puts "Processed %d, created %d, updated %d, errors %d" % [
      importer.processed, importer.created, importer.updated,
      importer.error_count
    ]
  end

  desc 'Process LPI CSV files in from_dir, moving them into to_dir.  Attribute the import to the given user.'
  task :process_dir, [:from_dir, :to_dir, :user_email] => [:environment] do |t, args|
    Dir.foreach(args[:from_dir]) do |filename|
      next unless filename =~ /\.csv$/
      full_filename = File.expand_path(filename, args[:from_dir])
      Rake::Task['lpi:import'].invoke(full_filename, args[:user_email])
      puts "Moving '%s' to '%s'" % [full_filename, args[:to_dir]]
      FileUtils.mv(full_filename, args[:to_dir])
    end
  end
end
