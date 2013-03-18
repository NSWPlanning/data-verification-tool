class AddTsvectorsToLocalGovernmentAreaRecord < ActiveRecord::Migration

  def up
    execute <<-SQL
      CREATE INDEX address_search
      ON local_government_area_records
      USING gin((to_tsvector('simple', COALESCE(ad_unit_no, ''::text))
        || to_tsvector('simple', COALESCE(ad_st_no_from, ''::text))
        || to_tsvector('simple', COALESCE(ad_st_no_to, ''::text))
        || to_tsvector('simple', COALESCE(ad_st_name, ''::text))
        || to_tsvector('simple', COALESCE(ad_st_type, ''::text))
        || to_tsvector('simple', COALESCE(ad_st_type_suffix, ''::text))
        || to_tsvector('simple', COALESCE(ad_postcode, ''::text))
        || to_tsvector('simple', COALESCE(ad_suburb, ''::text))
        || to_tsvector('simple', COALESCE(ad_lga_name, ''::text))))
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX address_search
    SQL
  end

end
