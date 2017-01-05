--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: activiy_journal_activity_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE activiy_journal_activity_type_enum AS ENUM (
    'unknown',
    'heart_rate',
    'steps'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activity_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE activity_journals (
    id integer NOT NULL,
    data json,
    user_id integer,
    activity_type activiy_journal_activity_type_enum DEFAULT 'unknown'::activiy_journal_activity_type_enum NOT NULL,
    journal_date timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone NOT NULL,
    data_hash character varying NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: activity_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activity_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activity_journals_id_seq OWNED BY activity_journals.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    provider character varying,
    uid character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    refresh_token character varying,
    access_token character varying,
    token_expires_at character varying,
    fitbit_oauth_client_id character varying,
    fitbit_oauth_client_secret character varying
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
-- Name: activity_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_journals ALTER COLUMN id SET DEFAULT nextval('activity_journals_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: activity_journals activity_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_journals
    ADD CONSTRAINT activity_journals_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_activity_journals_on_data_hash_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_activity_journals_on_data_hash_and_user_id ON activity_journals USING btree (data_hash, user_id);


--
-- Name: index_activity_journals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_journals_on_user_id ON activity_journals USING btree (user_id);


--
-- Name: activity_journals fk_rails_22e8881558; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_journals
    ADD CONSTRAINT fk_rails_22e8881558 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20161119133749'), ('20161125192448'), ('20161127103834'), ('20161127110902'), ('20161128185007'), ('20161128190028'), ('20161217221726'), ('20161218012457'), ('20161221032926'), ('20161221224501'), ('20161221225422'), ('20170105030707');


