--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acks; Type: TABLE; Schema: public; Owner: kudu; Tablespace: 
--

CREATE TABLE acks (
    id integer NOT NULL,
    score_id integer,
    identity integer NOT NULL,
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ip text,
    created_by_profile text
);


ALTER TABLE public.acks OWNER TO kudu;

--
-- Name: acks_id_seq; Type: SEQUENCE; Schema: public; Owner: kudu
--

CREATE SEQUENCE acks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acks_id_seq OWNER TO kudu;

--
-- Name: acks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kudu
--

ALTER SEQUENCE acks_id_seq OWNED BY acks.id;


--
-- Name: scores; Type: TABLE; Schema: public; Owner: kudu; Tablespace: 
--

CREATE TABLE scores (
    id integer NOT NULL,
    external_uid text NOT NULL,
    total_count integer DEFAULT 0,
    positive_count integer DEFAULT 0,
    negative_count integer DEFAULT 0,
    neutral_count integer DEFAULT 0,
    positive integer DEFAULT 0,
    negative integer DEFAULT 0,
    controversiality integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    histogram text,
    kind text NOT NULL,
    label_0 text,
    label_1 text,
    label_2 text,
    label_3 text,
    label_4 text,
    label_5 text,
    label_6 text,
    label_7 text,
    label_8 text,
    label_9 text
);


ALTER TABLE public.scores OWNER TO kudu;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: kudu
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_seq OWNER TO kudu;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kudu
--

ALTER SEQUENCE items_id_seq OWNED BY scores.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: kudu; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO kudu;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: kudu
--

ALTER TABLE ONLY acks ALTER COLUMN id SET DEFAULT nextval('acks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: kudu
--

ALTER TABLE ONLY scores ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: acks_pkey; Type: CONSTRAINT; Schema: public; Owner: kudu; Tablespace: 
--

ALTER TABLE ONLY acks
    ADD CONSTRAINT acks_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: kudu; Tablespace: 
--

ALTER TABLE ONLY scores
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: index_acks_on_identity; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_acks_on_identity ON acks USING btree (identity);


--
-- Name: index_acks_on_item_id; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_acks_on_item_id ON acks USING btree (score_id);


--
-- Name: index_acks_on_score; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_acks_on_score ON acks USING btree (value);


--
-- Name: index_items_on_controversiality; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_items_on_controversiality ON scores USING btree (controversiality);


--
-- Name: index_items_on_external_uid; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_items_on_external_uid ON scores USING btree (external_uid);


--
-- Name: index_items_on_negative_score; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_items_on_negative_score ON scores USING btree (negative);


--
-- Name: index_items_on_positive_score; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_items_on_positive_score ON scores USING btree (positive);


--
-- Name: index_scores_on_external_uid_and_kind; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE UNIQUE INDEX index_scores_on_external_uid_and_kind ON scores USING btree (external_uid, kind);


--
-- Name: index_scores_on_kind; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_scores_on_kind ON scores USING btree (kind);


--
-- Name: index_scores_on_labels; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE INDEX index_scores_on_labels ON scores USING btree (label_0, label_1, label_2, label_3, label_4, label_5, label_6, label_7, label_8, label_9);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: kudu; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: acks_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kudu
--

ALTER TABLE ONLY acks
    ADD CONSTRAINT acks_item_id_fkey FOREIGN KEY (score_id) REFERENCES scores(id);


--
-- PostgreSQL database dump complete
--

