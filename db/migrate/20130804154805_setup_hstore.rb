class SetupHstore < ActiveRecord::Migration
  def self.up
# Production boxes don't have the rights to do this    
#    execute "CREATE EXTENSION IF NOT EXISTS hstore"
  end

  def self.down
# Production boxes don't have the rights to do this        
#    execute "DROP EXTENSION IF EXISTS hstore"
  end
end
