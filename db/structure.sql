SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_registrations (
    id bigint NOT NULL,
    registration_id bigint,
    provider integer,
    external_id character varying,
    external_data json,
    external_data_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_registrations_id_seq OWNED BY public.external_registrations.id;


--
-- Name: ownerships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ownerships (
    id bigint NOT NULL,
    registration_id bigint,
    user_id bigint,
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id character varying,
    initial_owner_kind integer,
    creation_notification_kind integer
);


--
-- Name: ownerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ownerships_id_seq OWNED BY public.ownerships.id;


--
-- Name: public_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_images (
    id bigint NOT NULL,
    name character varying,
    image text,
    listing_order integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    imageable_type character varying,
    imageable_id bigint,
    uuid uuid DEFAULT public.gen_random_uuid(),
    external_url text
);


--
-- Name: public_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.public_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.public_images_id_seq OWNED BY public.public_images.id;


--
-- Name: registration_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_logs (
    id bigint NOT NULL,
    registration_id bigint,
    user_id bigint,
    ownership_id bigint,
    kind integer,
    authorizer integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    information text,
    uuid uuid DEFAULT public.gen_random_uuid(),
    user_description text
);


--
-- Name: registration_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registration_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registration_logs_id_seq OWNED BY public.registration_logs.id;


--
-- Name: registration_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_tags (
    id bigint NOT NULL,
    registration_id bigint,
    tag_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: registration_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registration_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registration_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registration_tags_id_seq OWNED BY public.registration_tags.id;


--
-- Name: registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registrations (
    id bigint NOT NULL,
    thumb_url character varying,
    description text,
    status integer DEFAULT 0,
    main_category_id bigint,
    manufacturer_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying,
    current_owner_id bigint,
    uuid uuid DEFAULT public.gen_random_uuid()
);


--
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registrations_id_seq OWNED BY public.registrations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying,
    slug character varying,
    main_category boolean,
    manufacturer boolean,
    parent_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: user_integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_integrations (
    id bigint NOT NULL,
    user_id bigint,
    auth_hash json,
    provider integer,
    external_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_integrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_integrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_integrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_integrations_id_seq OWNED BY public.user_integrations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    admin_role integer DEFAULT 0,
    admin_search_field text,
    api_key character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: external_registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_registrations ALTER COLUMN id SET DEFAULT nextval('public.external_registrations_id_seq'::regclass);


--
-- Name: ownerships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships ALTER COLUMN id SET DEFAULT nextval('public.ownerships_id_seq'::regclass);


--
-- Name: public_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_images ALTER COLUMN id SET DEFAULT nextval('public.public_images_id_seq'::regclass);


--
-- Name: registration_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_logs ALTER COLUMN id SET DEFAULT nextval('public.registration_logs_id_seq'::regclass);


--
-- Name: registration_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_tags ALTER COLUMN id SET DEFAULT nextval('public.registration_tags_id_seq'::regclass);


--
-- Name: registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations ALTER COLUMN id SET DEFAULT nextval('public.registrations_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: user_integrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_integrations ALTER COLUMN id SET DEFAULT nextval('public.user_integrations_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: external_registrations external_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_registrations
    ADD CONSTRAINT external_registrations_pkey PRIMARY KEY (id);


--
-- Name: ownerships ownerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships
    ADD CONSTRAINT ownerships_pkey PRIMARY KEY (id);


--
-- Name: public_images public_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_images
    ADD CONSTRAINT public_images_pkey PRIMARY KEY (id);


--
-- Name: registration_logs registration_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_logs
    ADD CONSTRAINT registration_logs_pkey PRIMARY KEY (id);


--
-- Name: registration_tags registration_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_tags
    ADD CONSTRAINT registration_tags_pkey PRIMARY KEY (id);


--
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: user_integrations user_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_integrations
    ADD CONSTRAINT user_integrations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_external_registrations_on_registration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_registrations_on_registration_id ON public.external_registrations USING btree (registration_id);


--
-- Name: index_ownerships_on_registration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ownerships_on_registration_id ON public.ownerships USING btree (registration_id);


--
-- Name: index_ownerships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ownerships_on_user_id ON public.ownerships USING btree (user_id);


--
-- Name: index_public_images_on_imageable_type_and_imageable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_public_images_on_imageable_type_and_imageable_id ON public.public_images USING btree (imageable_type, imageable_id);


--
-- Name: index_registration_logs_on_ownership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registration_logs_on_ownership_id ON public.registration_logs USING btree (ownership_id);


--
-- Name: index_registration_logs_on_registration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registration_logs_on_registration_id ON public.registration_logs USING btree (registration_id);


--
-- Name: index_registration_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registration_logs_on_user_id ON public.registration_logs USING btree (user_id);


--
-- Name: index_registration_tags_on_registration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registration_tags_on_registration_id ON public.registration_tags USING btree (registration_id);


--
-- Name: index_registration_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registration_tags_on_tag_id ON public.registration_tags USING btree (tag_id);


--
-- Name: index_registrations_on_current_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_current_owner_id ON public.registrations USING btree (current_owner_id);


--
-- Name: index_registrations_on_main_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_main_category_id ON public.registrations USING btree (main_category_id);


--
-- Name: index_registrations_on_manufacturer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_manufacturer_id ON public.registrations USING btree (manufacturer_id);


--
-- Name: index_tags_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_parent_id ON public.tags USING btree (parent_id);


--
-- Name: index_user_integrations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_integrations_on_user_id ON public.user_integrations USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190130221535'),
('20190203031814'),
('20190203201834'),
('20190203230824'),
('20190203232211'),
('20190204231506'),
('20190206191233'),
('20190206191609'),
('20190214180052'),
('20190214182953'),
('20190214183813'),
('20190214200816'),
('20190214214716'),
('20190214214825'),
('20190218210702'),
('20190219193533'),
('20190219194700'),
('20190527185828'),
('20190611181447'),
('20190612180110'),
('20190612194613'),
('20190619152358');


