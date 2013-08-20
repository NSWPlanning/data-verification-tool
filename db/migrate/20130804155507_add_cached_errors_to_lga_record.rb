class AddCachedErrorsToLgaRecord < ActiveRecord::Migration
  def change
    # A defined default value is needed because the default value for a hstore column 
    # is null.
    # When you do error_details = error_details || ('foo' => 'bar'), if error_details
    # is null, then null || ('foo' => 'bar') = null. Which is not the desired result;
    # it means that empty columns will never have anything added to them.
    # More: http://stackoverflow.com/questions/9317971/adding-a-key-to-an-empty-hstore-column
    #

    # See also the after_initialize :init hack in LocalGovernmentAreaRecord.
    
    # Can't use add_column, as it quotes the default value, and we end up trying to set an hstore column to a string
    #  add_column :local_government_area_records, :error_details, :hstore, default: "hstore(array[]::varchar[])"    
    execute 'ALTER TABLE "local_government_area_records" ADD COLUMN "error_details" hstore DEFAULT hstore(array[]::varchar[]) NOT NULL'

  end
end
