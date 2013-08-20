--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: queue_classic_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE queue_classic_jobs (
    id integer NOT NULL,
    q_name character varying(255),
    method character varying(255),
    args text,
    locked_at timestamp without time zone
);


--
-- Name: lock_head(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION lock_head(tname character varying) RETURNS SETOF queue_classic_jobs
    LANGUAGE plpgsql
    AS $_$
BEGIN
  RETURN QUERY EXECUTE 'SELECT * FROM lock_head($1,10)' USING tname;
END;
$_$;


--
-- Name: lock_head(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION lock_head(q_name character varying, top_boundary integer) RETURNS SETOF queue_classic_jobs
    LANGUAGE plpgsql
    AS $_$
DECLARE
  unlocked integer;
  relative_top integer;
  job_count integer;
BEGIN
  -- The purpose is to release contention for the first spot in the table.
  -- The select count(*) is going to slow down dequeue performance but allow
  -- for more workers. Would love to see some optimization here...

  EXECUTE 'SELECT count(*) FROM '
    || '(SELECT * FROM queue_classic_jobs WHERE q_name = '
    || quote_literal(q_name)
    || ' LIMIT '
    || quote_literal(top_boundary)
    || ') limited'
  INTO job_count;

  SELECT TRUNC(random() * (top_boundary - 1))
  INTO relative_top;

  IF job_count < top_boundary THEN
    relative_top = 0;
  END IF;

  LOOP
    BEGIN
      EXECUTE 'SELECT id FROM queue_classic_jobs '
        || ' WHERE locked_at IS NULL'
        || ' AND q_name = '
        || quote_literal(q_name)
        || ' ORDER BY id ASC'
        || ' LIMIT 1'
        || ' OFFSET ' || quote_literal(relative_top)
        || ' FOR UPDATE NOWAIT'
      INTO unlocked;
      EXIT;
    EXCEPTION
      WHEN lock_not_available THEN
        -- do nothing. loop again and hope we get a lock
    END;
  END LOOP;

  RETURN QUERY EXECUTE 'UPDATE queue_classic_jobs '
    || ' SET locked_at = (CURRENT_TIMESTAMP)'
    || ' WHERE id = $1'
    || ' AND locked_at is NULL'
    || ' RETURNING *'
  USING unlocked;

  RETURN;
END;
$_$;


--
-- Name: land_and_property_information_import_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE land_and_property_information_import_logs (
    id integer NOT NULL,
    filename character varying(255),
    user_id integer,
    processed integer DEFAULT 0,
    created integer DEFAULT 0,
    updated integer DEFAULT 0,
    deleted integer DEFAULT 0,
    error_count integer DEFAULT 0,
    finished boolean DEFAULT false,
    success boolean DEFAULT false,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: land_and_property_information_import_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE land_and_property_information_import_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: land_and_property_information_import_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE land_and_property_information_import_logs_id_seq OWNED BY land_and_property_information_import_logs.id;


--
-- Name: land_and_property_information_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE land_and_property_information_records (
    id integer NOT NULL,
    cadastre_id character varying(255) NOT NULL,
    lot_number character varying(255),
    section_number character varying(255),
    plan_label character varying(255),
    title_reference character varying(255) NOT NULL,
    lga_name character varying(255) NOT NULL,
    start_date character varying(255),
    end_date character varying(255),
    modified_date character varying(255),
    last_update character varying(255),
    md5sum character varying(32) NOT NULL,
    local_government_area_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    retired boolean DEFAULT false
);


--
-- Name: land_and_property_information_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE land_and_property_information_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: land_and_property_information_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE land_and_property_information_records_id_seq OWNED BY land_and_property_information_records.id;


--
-- Name: local_government_area_record_import_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE local_government_area_record_import_logs (
    id integer NOT NULL,
    filename character varying(255),
    user_id integer,
    local_government_area_id integer,
    processed integer DEFAULT 0,
    created integer DEFAULT 0,
    updated integer DEFAULT 0,
    deleted integer DEFAULT 0,
    error_count integer DEFAULT 0,
    finished boolean DEFAULT false,
    success boolean DEFAULT false,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_quality text,
    council_file_statistics text,
    invalid_records text,
    land_parcel_statistics text,
    lpi_comparison text
);


--
-- Name: local_government_area_record_import_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE local_government_area_record_import_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: local_government_area_record_import_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE local_government_area_record_import_logs_id_seq OWNED BY local_government_area_record_import_logs.id;


--
-- Name: local_government_area_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE local_government_area_records (
    id integer NOT NULL,
    local_government_area_id integer,
    date_of_update character varying(255),
    council_id character varying(255),
    if_partial_lot character varying(255),
    dp_lot_number character varying(255),
    dp_section_number character varying(255),
    dp_plan_number character varying(255),
    ad_unit_no character varying(255),
    ad_st_no_from character varying(255),
    ad_st_no_to character varying(255),
    ad_st_name character varying(255),
    ad_st_type character varying(255),
    ad_st_type_suffix character varying(255),
    ad_postcode character varying(255),
    ad_suburb character varying(255),
    ad_lga_name character varying(255),
    land_area character varying(255),
    frontage character varying(255),
    lep_nsi_zone character varying(255),
    lep_si_zone character varying(255),
    if_critical_habitat character varying(255),
    if_wilderness character varying(255),
    if_heritage_item character varying(255),
    if_heritage_conservation_area character varying(255),
    if_heritage_conservation_area_draft character varying(255),
    if_coastal_water character varying(255),
    if_coastal_lake character varying(255),
    if_sepp14_with_100m_buffer character varying(255),
    if_sepp26_with_100m_buffer character varying(255),
    if_aquatic_reserve_with_100m_buffer character varying(255),
    if_wet_land_with_100m_buffer character varying(255),
    if_aboriginal_significance character varying(255),
    if_biodiversity_significance character varying(255),
    if_land_reserved_national_park character varying(255),
    if_land_reserved_flora_fauna_geo character varying(255),
    if_land_reserved_public_purpose character varying(255),
    if_unsewered_land character varying(255),
    if_acid_sulfate_soil character varying(255),
    if_fire_prone_area character varying(255),
    if_flood_control_lot character varying(255),
    ex_buffer_area character varying(255),
    ex_coastal_erosion_hazard character varying(255),
    ex_ecological_sensitive_area character varying(255),
    ex_protected_area character varying(255),
    if_foreshore_area character varying(255),
    ex_environmentally_sensitive_land character varying(255),
    if_anef25 character varying(255),
    transaction_type character varying(255),
    if_western_sydney_parkland character varying(255),
    if_river_front character varying(255),
    if_land_biobanking character varying(255),
    if_sydney_water_special_area character varying(255),
    if_sepp_alpine_resorts character varying(255),
    if_siding_springs_18km_buffer character varying(255),
    acid_sulfate_soil_class character varying(255),
    if_mine_subsidence character varying(255),
    if_local_heritage_item character varying(255),
    if_orana_rep character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    md5sum character varying(32) NOT NULL,
    land_and_property_information_record_id integer,
    is_valid boolean DEFAULT true,
    "Ex_exempt_schedule_4" character varying(255),
    "Ex_complying_schedule_5" character varying(255),
    "Ex_contaminated_land" character varying(255),
    "If_SEPP_rural_lands" character varying(255),
    error_details hstore DEFAULT hstore((ARRAY[]::character varying[])::text[]) NOT NULL
);


--
-- Name: local_government_area_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE local_government_area_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: local_government_area_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE local_government_area_records_id_seq OWNED BY local_government_area_records.id;


--
-- Name: local_government_areas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE local_government_areas (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lpi_alias character varying(255),
    lga_alias character varying(255),
    filename_alias character varying(255)
);


--
-- Name: local_government_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE local_government_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: local_government_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE local_government_areas_id_seq OWNED BY local_government_areas.id;


--
-- Name: local_government_areas_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE local_government_areas_users (
    local_government_area_id integer,
    user_id integer
);


--
-- Name: non_standard_instrumentation_zone_import_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE non_standard_instrumentation_zone_import_logs (
    id integer NOT NULL,
    filename character varying(255),
    user_id integer,
    local_government_area_id integer,
    processed integer DEFAULT 0,
    created integer DEFAULT 0,
    updated integer DEFAULT 0,
    deleted integer DEFAULT 0,
    error_count integer DEFAULT 0,
    finished boolean DEFAULT false,
    success boolean DEFAULT false,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: non_standard_instrumentation_zone_import_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE non_standard_instrumentation_zone_import_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_standard_instrumentation_zone_import_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE non_standard_instrumentation_zone_import_logs_id_seq OWNED BY non_standard_instrumentation_zone_import_logs.id;


--
-- Name: non_standard_instrumentation_zones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE non_standard_instrumentation_zones (
    id integer NOT NULL,
    local_government_area_id integer,
    council_id integer,
    date_of_update text,
    lep_nsi_zone text,
    lep_si_zone text,
    lep_name text,
    md5sum character varying(32) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: non_standard_instrumentation_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE non_standard_instrumentation_zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_standard_instrumentation_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE non_standard_instrumentation_zones_id_seq OWNED BY non_standard_instrumentation_zones.id;


--
-- Name: queue_classic_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE queue_classic_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: queue_classic_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE queue_classic_jobs_id_seq OWNED BY queue_classic_jobs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    crypted_password character varying(255),
    salt character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    roles integer,
    reset_password_token character varying(255),
    reset_password_token_expires_at timestamp without time zone,
    reset_password_email_sent_at timestamp without time zone,
    name character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY land_and_property_information_import_logs ALTER COLUMN id SET DEFAULT nextval('land_and_property_information_import_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY land_and_property_information_records ALTER COLUMN id SET DEFAULT nextval('land_and_property_information_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY local_government_area_record_import_logs ALTER COLUMN id SET DEFAULT nextval('local_government_area_record_import_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY local_government_area_records ALTER COLUMN id SET DEFAULT nextval('local_government_area_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY local_government_areas ALTER COLUMN id SET DEFAULT nextval('local_government_areas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY non_standard_instrumentation_zone_import_logs ALTER COLUMN id SET DEFAULT nextval('non_standard_instrumentation_zone_import_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY non_standard_instrumentation_zones ALTER COLUMN id SET DEFAULT nextval('non_standard_instrumentation_zones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY queue_classic_jobs ALTER COLUMN id SET DEFAULT nextval('queue_classic_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: land_and_property_information_import_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY land_and_property_information_import_logs
    ADD CONSTRAINT land_and_property_information_import_logs_pkey PRIMARY KEY (id);


--
-- Name: land_and_property_information_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY land_and_property_information_records
    ADD CONSTRAINT land_and_property_information_records_pkey PRIMARY KEY (id);


--
-- Name: local_government_area_record_import_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY local_government_area_record_import_logs
    ADD CONSTRAINT local_government_area_record_import_logs_pkey PRIMARY KEY (id);


--
-- Name: local_government_area_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY local_government_area_records
    ADD CONSTRAINT local_government_area_records_pkey PRIMARY KEY (id);


--
-- Name: local_government_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY local_government_areas
    ADD CONSTRAINT local_government_areas_pkey PRIMARY KEY (id);


--
-- Name: non_standard_instrumentation_zone_import_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY non_standard_instrumentation_zone_import_logs
    ADD CONSTRAINT non_standard_instrumentation_zone_import_logs_pkey PRIMARY KEY (id);


--
-- Name: non_standard_instrumentation_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY non_standard_instrumentation_zones
    ADD CONSTRAINT non_standard_instrumentation_zones_pkey PRIMARY KEY (id);


--
-- Name: queue_classic_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY queue_classic_jobs
    ADD CONSTRAINT queue_classic_jobs_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: address_search; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX address_search ON local_government_area_records USING gin ((((((((((to_tsvector('simple'::regconfig, (COALESCE(ad_unit_no, (''::text)::character varying))::text) || to_tsvector('simple'::regconfig, (COALESCE(ad_st_no_from, (''::text)::character varying))::text)) || to_tsvector('simple'::regconfig, (COALESCE(ad_st_no_to, (''::text)::character varying))::text)) || to_tsvector('simple'::regconfig, (COALESCE(ad_st_name, (''::text)::character varying))::text)) || to_tsvector('simple'::regconfig, (COALESCE(ad_st_type, (''::text)::character varying))::text)) || to_tsvector('simple'::regconfig, (COALESCE(ad_st_type_suffix, (''::text)::character varying))::text)) || to_tsvector('simple'::regconfig, (COALESCE(ad_postcode, (''::text)::character varying))::text)) || to_tsvector('simple'::regconfig, (COALESCE(ad_suburb, (''::text)::character varying))::text)) || to_tsvector('simple'::regconfig, (COALESCE(ad_lga_name, (''::text)::character varying))::text))));


--
-- Name: idx_qc_on_name_only_unlocked; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_qc_on_name_only_unlocked ON queue_classic_jobs USING btree (q_name, id);


--
-- Name: index_land_and_property_information_import_logs_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_land_and_property_information_import_logs_on_user_id ON land_and_property_information_import_logs USING btree (user_id);


--
-- Name: index_lga_import_log_lga_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lga_import_log_lga_id ON local_government_area_record_import_logs USING btree (local_government_area_id);


--
-- Name: index_lgas_users; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lgas_users ON local_government_areas_users USING btree (local_government_area_id, user_id);


--
-- Name: index_local_government_area_record_import_logs_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_local_government_area_record_import_logs_on_user_id ON local_government_area_record_import_logs USING btree (user_id);


--
-- Name: index_local_government_area_records_on_error_details; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_local_government_area_records_on_error_details ON local_government_area_records USING gist (error_details);


--
-- Name: index_local_government_area_records_on_local_government_area_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_local_government_area_records_on_local_government_area_id ON local_government_area_records USING btree (local_government_area_id);


--
-- Name: index_non_standard_instrumentation_zone_import_logs_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_non_standard_instrumentation_zone_import_logs_on_user_id ON non_standard_instrumentation_zone_import_logs USING btree (user_id);


--
-- Name: index_nsi_council_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nsi_council_id ON non_standard_instrumentation_zones USING btree (council_id);


--
-- Name: index_nsi_import_log_nsi_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nsi_import_log_nsi_id ON non_standard_instrumentation_zone_import_logs USING btree (local_government_area_id);


--
-- Name: index_nsi_local_government_area_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nsi_local_government_area_id ON non_standard_instrumentation_zones USING btree (local_government_area_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: lga_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX lga_id_index ON land_and_property_information_records USING btree (local_government_area_id);


--
-- Name: lpi_cadastre_id_lga_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX lpi_cadastre_id_lga_id ON land_and_property_information_records USING btree (cadastre_id, local_government_area_id);


--
-- Name: plan_label; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX plan_label ON land_and_property_information_records USING btree (plan_label);


--
-- Name: title_reference; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX title_reference ON local_government_area_records USING btree (dp_plan_number, dp_section_number, dp_lot_number);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120724223540');

INSERT INTO schema_migrations (version) VALUES ('20120725233950');

INSERT INTO schema_migrations (version) VALUES ('20120726025837');

INSERT INTO schema_migrations (version) VALUES ('20120727034351');

INSERT INTO schema_migrations (version) VALUES ('20120729222751');

INSERT INTO schema_migrations (version) VALUES ('20120801022417');

INSERT INTO schema_migrations (version) VALUES ('20120806221235');

INSERT INTO schema_migrations (version) VALUES ('20120808223750');

INSERT INTO schema_migrations (version) VALUES ('20120814224452');

INSERT INTO schema_migrations (version) VALUES ('20120815033833');

INSERT INTO schema_migrations (version) VALUES ('20120823012039');

INSERT INTO schema_migrations (version) VALUES ('20120823231352');

INSERT INTO schema_migrations (version) VALUES ('20120824033811');

INSERT INTO schema_migrations (version) VALUES ('20120827040325');

INSERT INTO schema_migrations (version) VALUES ('20120827041200');

INSERT INTO schema_migrations (version) VALUES ('20120830025711');

INSERT INTO schema_migrations (version) VALUES ('20120830030924');

INSERT INTO schema_migrations (version) VALUES ('20120831014454');

INSERT INTO schema_migrations (version) VALUES ('20120903022649');

INSERT INTO schema_migrations (version) VALUES ('20120903041751');

INSERT INTO schema_migrations (version) VALUES ('20120913014707');

INSERT INTO schema_migrations (version) VALUES ('20120913020021');

INSERT INTO schema_migrations (version) VALUES ('20120913041527');

INSERT INTO schema_migrations (version) VALUES ('20120917221421');

INSERT INTO schema_migrations (version) VALUES ('20120918011155');

INSERT INTO schema_migrations (version) VALUES ('20121212020722');

INSERT INTO schema_migrations (version) VALUES ('20130311000210');

INSERT INTO schema_migrations (version) VALUES ('20130312044650');

INSERT INTO schema_migrations (version) VALUES ('20130313055749');

INSERT INTO schema_migrations (version) VALUES ('20130411043338');

INSERT INTO schema_migrations (version) VALUES ('20130416074310');

INSERT INTO schema_migrations (version) VALUES ('20130717093016');

INSERT INTO schema_migrations (version) VALUES ('20130717102731');

INSERT INTO schema_migrations (version) VALUES ('20130717133612');

INSERT INTO schema_migrations (version) VALUES ('20130717134320');

INSERT INTO schema_migrations (version) VALUES ('20130804154805');

INSERT INTO schema_migrations (version) VALUES ('20130804155507');

INSERT INTO schema_migrations (version) VALUES ('20130818131550');