class SetupHstore < ActiveRecord::Migration
  def self.up
    # Creating hstore extension in a given database requires
    #  superuser permission, which we will not have on production. It has
    #  to be run manually.
    if RAILS_ENV != 'production' 
      execute "CREATE EXTENSION IF NOT EXISTS hstore"
    end
  end

  def self.down
    # Removing hstore extension in a given database requires
    #  superuser permission, which we will not have on production. 
    #  It has to be run manually.
    if RAILS_ENV != 'production'
      execute "DROP EXTENSION IF EXISTS hstore"
    end
  end
end
