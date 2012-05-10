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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE acks (
    id integer NOT NULL,
    score_id integer,
    identity integer NOT NULL,
    value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: acks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE acks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: acks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE acks_id_seq OWNED BY acks.id;


--
-- Name: scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scores (
    id integer NOT NULL,
    external_uid text NOT NULL,
    path text,
    total_count integer DEFAULT 0,
    positive_count integer DEFAULT 0,
    negative_count integer DEFAULT 0,
    neutral_count integer DEFAULT 0,
    total_positive integer DEFAULT 0,
    total_negative integer DEFAULT 0,
    controversiality integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    histogram text
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY scores.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE acks ALTER COLUMN id SET DEFAULT nextval('acks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE scores ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: acks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY acks
    ADD CONSTRAINT acks_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scores
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: index_acks_on_identity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_acks_on_identity ON acks USING btree (identity);


--
-- Name: index_acks_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_acks_on_item_id ON acks USING btree (score_id);


--
-- Name: index_acks_on_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_acks_on_score ON acks USING btree (value);


--
-- Name: index_items_on_controversiality; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_controversiality ON scores USING btree (controversiality);


--
-- Name: index_items_on_external_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_external_uid ON scores USING btree (external_uid);


--
-- Name: index_items_on_negative_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_negative_score ON scores USING btree (total_negative);


--
-- Name: index_items_on_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_path ON scores USING btree (path);


--
-- Name: index_items_on_positive_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_positive_score ON scores USING btree (total_positive);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: acks_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY acks
    ADD CONSTRAINT acks_item_id_fkey FOREIGN KEY (score_id) REFERENCES scores(id);


--
-- PostgreSQL database dump complete
--

