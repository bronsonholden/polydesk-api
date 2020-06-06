SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_controls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_controls (
    id bigint NOT NULL,
    group_id bigint,
    namespace character varying NOT NULL,
    mode smallint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: access_controls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.access_controls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_controls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_controls_id_seq OWNED BY public.access_controls.id;


--
-- Name: account_user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_user_groups (
    id bigint NOT NULL,
    account_user_id bigint,
    group_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: account_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_user_groups_id_seq OWNED BY public.account_user_groups.id;


--
-- Name: account_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_users (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role integer DEFAULT 0
);


--
-- Name: account_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_users_id_seq OWNED BY public.account_users.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id bigint NOT NULL,
    identifier character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


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
-- Name: blueprints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blueprints (
    id bigint NOT NULL,
    name character varying NOT NULL,
    namespace character varying NOT NULL,
    schema json NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    view json NOT NULL,
    construction_view json,
    list_view json,
    CONSTRAINT check_blueprints_on_namespace CHECK (((namespace)::text ~* '^[a-z\-_0-9]+$'::text))
);


--
-- Name: blueprints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blueprints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blueprints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blueprints_id_seq OWNED BY public.blueprints.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    content character varying,
    file_size integer,
    content_type character varying,
    discarded_at timestamp without time zone,
    folder_id bigint DEFAULT 0 NOT NULL,
    unique_enforcer smallint DEFAULT 0,
    content_data jsonb
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folders (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unique_enforcer smallint DEFAULT 0,
    discarded_at timestamp without time zone,
    folder_id bigint
);


--
-- Name: folders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: folders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.folders_id_seq OWNED BY public.folders.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: old_prefabs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.old_prefabs (
    id bigint NOT NULL,
    blueprint_id bigint,
    namespace character varying NOT NULL,
    tag integer NOT NULL,
    schema json NOT NULL,
    view json NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    flat_data jsonb
);


--
-- Name: old_prefabs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.old_prefabs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: old_prefabs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.old_prefabs_id_seq OWNED BY public.old_prefabs.id;


--
-- Name: options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.options (
    id bigint NOT NULL,
    name integer NOT NULL,
    value character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.options_id_seq OWNED BY public.options.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    code integer NOT NULL,
    account_user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: prefabs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prefabs (
    id bigint NOT NULL,
    blueprint_id bigint,
    namespace character varying NOT NULL,
    schema json NOT NULL,
    view json NOT NULL,
    data jsonb NOT NULL,
    flat_data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
)
PARTITION BY LIST (namespace);


--
-- Name: prefabs_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prefabs_template (
    id bigint NOT NULL,
    blueprint_id bigint,
    namespace character varying NOT NULL,
    schema json NOT NULL,
    view json NOT NULL,
    data jsonb NOT NULL,
    flat_data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT check_prefabs_template_on_namespace CHECK (((namespace)::text ~* '^[a-z\-_0-9]+$'::text))
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    provider character varying DEFAULT 'email'::character varying NOT NULL,
    uid character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    allow_password_change boolean DEFAULT false,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    nickname character varying,
    image character varying,
    email character varying NOT NULL,
    tokens json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    default_account_id bigint,
    first_name character varying,
    last_name character varying
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
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: access_controls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_controls ALTER COLUMN id SET DEFAULT nextval('public.access_controls_id_seq'::regclass);


--
-- Name: account_user_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_user_groups ALTER COLUMN id SET DEFAULT nextval('public.account_user_groups_id_seq'::regclass);


--
-- Name: account_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_users ALTER COLUMN id SET DEFAULT nextval('public.account_users_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: blueprints id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blueprints ALTER COLUMN id SET DEFAULT nextval('public.blueprints_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: folders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders ALTER COLUMN id SET DEFAULT nextval('public.folders_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: old_prefabs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.old_prefabs ALTER COLUMN id SET DEFAULT nextval('public.old_prefabs_id_seq'::regclass);


--
-- Name: options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options ALTER COLUMN id SET DEFAULT nextval('public.options_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: access_controls access_controls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_controls
    ADD CONSTRAINT access_controls_pkey PRIMARY KEY (id);


--
-- Name: account_user_groups account_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_user_groups
    ADD CONSTRAINT account_user_groups_pkey PRIMARY KEY (id);


--
-- Name: account_users account_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_users
    ADD CONSTRAINT account_users_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: blueprints blueprints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blueprints
    ADD CONSTRAINT blueprints_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: old_prefabs old_prefabs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.old_prefabs
    ADD CONSTRAINT old_prefabs_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: prefabs_template prefabs_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prefabs_template
    ADD CONSTRAINT prefabs_template_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_access_controls_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_controls_on_group_id ON public.access_controls USING btree (group_id);


--
-- Name: index_access_controls_on_group_id_and_namespace_and_mode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_controls_on_group_id_and_namespace_and_mode ON public.access_controls USING btree (group_id, namespace, mode);


--
-- Name: index_account_user_groups_on_account_user_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_account_user_groups_on_account_user_id_and_group_id ON public.account_user_groups USING btree (account_user_id, group_id);


--
-- Name: index_account_user_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_user_groups_on_group_id ON public.account_user_groups USING btree (group_id);


--
-- Name: index_account_users_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_users_on_account_id ON public.account_users USING btree (account_id);


--
-- Name: index_account_users_on_account_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_account_users_on_account_id_and_user_id ON public.account_users USING btree (account_id, user_id);


--
-- Name: index_account_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_users_on_user_id ON public.account_users USING btree (user_id);


--
-- Name: index_accounts_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_discarded_at ON public.accounts USING btree (discarded_at);


--
-- Name: index_blueprints_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_blueprints_on_name ON public.blueprints USING btree (name);


--
-- Name: index_blueprints_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_blueprints_on_namespace ON public.blueprints USING btree (namespace);


--
-- Name: index_documents_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_discarded_at ON public.documents USING btree (discarded_at);


--
-- Name: index_documents_on_folder_id_and_name_and_unique_enforcer; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_documents_on_folder_id_and_name_and_unique_enforcer ON public.documents USING btree (folder_id, name, unique_enforcer);


--
-- Name: index_folders_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_folders_on_discarded_at ON public.folders USING btree (discarded_at);


--
-- Name: index_folders_on_folder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_folders_on_folder_id ON public.folders USING btree (folder_id);


--
-- Name: index_folders_on_folder_id_and_name_and_unique_enforcer; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_folders_on_folder_id_and_name_and_unique_enforcer ON public.folders USING btree (folder_id, name, unique_enforcer);


--
-- Name: index_groups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_name ON public.groups USING btree (name);


--
-- Name: index_old_prefabs_on_blueprint_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_old_prefabs_on_blueprint_id ON public.old_prefabs USING btree (blueprint_id);


--
-- Name: index_old_prefabs_on_namespace_and_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_old_prefabs_on_namespace_and_tag ON public.old_prefabs USING btree (namespace, tag);


--
-- Name: index_options_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_options_on_name ON public.options USING btree (name);


--
-- Name: index_permissions_on_code_and_account_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_code_and_account_user_id ON public.permissions USING btree (code, account_user_id);


--
-- Name: index_prefabs_on_blueprint_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prefabs_on_blueprint_id ON ONLY public.prefabs USING btree (blueprint_id);


--
-- Name: index_prefabs_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prefabs_on_uid ON public.old_prefabs USING btree (((((namespace)::text || '/'::text) || tag)));


--
-- Name: index_prefabs_template_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prefabs_template_on_uid ON public.prefabs_template USING btree (((((namespace)::text || '/'::text) || id)));


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_default_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_default_account_id ON public.users USING btree (default_account_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uid_and_provider ON public.users USING btree (uid, provider);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: prefabs_template_blueprint_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prefabs_template_blueprint_id_idx ON public.prefabs_template USING btree (blueprint_id);


--
-- Name: access_controls fk_rails_009e83fdfa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_controls
    ADD CONSTRAINT fk_rails_009e83fdfa FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: old_prefabs fk_rails_0909d3a820; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.old_prefabs
    ADD CONSTRAINT fk_rails_0909d3a820 FOREIGN KEY (blueprint_id) REFERENCES public.blueprints(id);


--
-- Name: prefabs fk_rails_0909d3a820; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.prefabs
    ADD CONSTRAINT fk_rails_0909d3a820 FOREIGN KEY (blueprint_id) REFERENCES public.blueprints(id);


--
-- Name: account_users fk_rails_685e030c15; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_users
    ADD CONSTRAINT fk_rails_685e030c15 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_68e8c5de71; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_68e8c5de71 FOREIGN KEY (default_account_id) REFERENCES public.accounts(id);


--
-- Name: account_users fk_rails_c96445f213; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_users
    ADD CONSTRAINT fk_rails_c96445f213 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: account_user_groups fk_rails_ce21b5b188; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_user_groups
    ADD CONSTRAINT fk_rails_ce21b5b188 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20181220052004'),
('20181221055252'),
('20181230093550'),
('20181230103647'),
('20181230103709'),
('20190103035242'),
('20190103055326'),
('20190107020145'),
('20190107064150'),
('20190107070919'),
('20190107071224'),
('20190107071432'),
('20190107072400'),
('20190107072612'),
('20190107074705'),
('20190120205909'),
('20190120213236'),
('20190210223653'),
('20190217043912'),
('20190308072035'),
('20190308072858'),
('20190317085541'),
('20190319010015'),
('20190319074917'),
('20190319075135'),
('20190320044105'),
('20190320044536'),
('20190320044646'),
('20190401025411'),
('20190409035019'),
('20190410005504'),
('20190413035738'),
('20190417042331'),
('20190417043308'),
('20190418012539'),
('20190418020742'),
('20190418025642'),
('20190418025840'),
('20190418030302'),
('20190418031249'),
('20190420025600'),
('20190428194901'),
('20190505010159'),
('20190529050219'),
('20190604015640'),
('20190606032113'),
('20190610060609'),
('20190611045949'),
('20190611060209'),
('20190612041053'),
('20190612041514'),
('20190720232937'),
('20190908235624'),
('20191001011248'),
('20191130064241'),
('20191202051611'),
('20191209044544'),
('20191209045440'),
('20200121065310'),
('20200128055725'),
('20200129015950'),
('20200304054342'),
('20200312054014'),
('20200407051513'),
('20200407060222'),
('20200412045542'),
('20200505041315'),
('20200525071102'),
('20200606040322'),
('20200606041049');


