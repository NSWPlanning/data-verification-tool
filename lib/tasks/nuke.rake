namespace :db do
  desc "nuke the database"
  task :nuke do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    # This app uses `structure.sql`.
    # Rake::Task["db:schema:load"].invoke
    Rake::Task["db:structure:load"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["db:test:clone"].invoke
  end
end
