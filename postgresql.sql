--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 16.3

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

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: postgres
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO postgres;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO postgres;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO postgres;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO postgres;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO postgres;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    ee_client_id text,
    ee_client_secret text
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO postgres;

--
-- Name: collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collections (
    collection_id uuid DEFAULT gen_random_uuid() NOT NULL,
    collection_name text NOT NULL
);


ALTER TABLE public.collections OWNER TO postgres;

--
-- Name: collections_vs_authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collections_vs_authors (
    collection_id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.collections_vs_authors OWNER TO postgres;

--
-- Name: collections_vs_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collections_vs_images (
    collection_id uuid NOT NULL,
    image_id uuid NOT NULL
);


ALTER TABLE public.collections_vs_images OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images (
    image_id uuid DEFAULT gen_random_uuid() NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT 'unchecked'::text NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.images OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    tag_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: tags_vs_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags_vs_images (
    tag_id uuid NOT NULL,
    image_id uuid NOT NULL
);


ALTER TABLE public.tags_vs_images OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_vs_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_vs_roles (
    user_id uuid NOT NULL,
    role text NOT NULL
);


ALTER TABLE public.users_vs_roles OWNER TO postgres;

--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--



--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--



--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--



--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

INSERT INTO hdb_catalog.hdb_metadata VALUES (1, '{"actions":[{"definition":{"arguments":[{"name":"token","type":"String!"},{"name":"user_id","type":"uuid!"},{"name":"role","type":"String!"}],"handler":"http://actions-backend.api:3000/users/roles","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"AddAuthorByTokenOutput","request_transform":{"method":"POST","query_params":{"jwt":"{{$body.input.token}}"},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"AddAuthorByToken"},{"definition":{"arguments":[{"name":"user_id","type":"uuid!"},{"name":"collection_id","type":"uuid!"},{"name":"token","type":"String!"}],"handler":"http://actions-backend.api:3000/collections/authors","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"AddAuthorToCollectionByTokenOutput","request_transform":{"method":"PUT","query_params":{"jwt":"{{$body.input.token}}"},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"AddAuthorToCollectionByToken"},{"definition":{"arguments":[{"name":"token","type":"String!"},{"name":"collection_name","type":"String!"}],"handler":"http://actions-backend.api:3000/collections","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"AddCollectionOutput","request_transform":{"method":"POST","query_params":{"jwt":"{{$body.input.token}}"},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"AddCollection"},{"definition":{"arguments":[{"name":"base64","type":"String"},{"name":"link","type":"String"},{"name":"token","type":"String!"}],"handler":"http://actions-backend.api:3000/images","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"AddImageByTokenOutput","request_transform":{"method":"POST","query_params":{"jwt":"{{$body.input.token}}"},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"AddImageByToken"},{"definition":{"arguments":[{"name":"collection_id","type":"uuid!"},{"name":"image_id","type":"uuid!"},{"name":"token","type":"String!"}],"handler":"http://actions-backend.api:3000/collections/images","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"AddImageVsCollectionRelationMutationOutput","request_transform":{"method":"PUT","query_params":{"jwt":"{{$body.input.token}}"},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"AddImageVsCollectionRelationMutationByToken"},{"definition":{"arguments":[{"name":"tag_name","type":"String!"},{"name":"image_id","type":"uuid!"},{"name":"token","type":"String!"}],"handler":"http://actions-backend.api:3000/images/tags","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"AddTagsToImageByTokenOutput","request_transform":{"method":"POST","query_params":{"jwt":"{{$body.input.token}}"},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"AddTagToImageByToken"},{"definition":{"arguments":[{"name":"email","type":"String!"},{"name":"password","type":"String!"}],"handler":"http://actions-backend.api:3000/users","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"AddUserOutput","request_transform":{"method":"POST","query_params":{},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"AddUser"},{"definition":{"arguments":[{"name":"image_id","type":"uuid"},{"name":"status","type":"String"},{"name":"url","type":"String"},{"name":"user_id","type":"uuid"}],"handler":"http://actions-backend.api:3000/public/images","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"output_type":"[ImagesForPublicOutput]","request_transform":{"method":"POST","query_params":{},"template_engine":"Kriti","version":2},"type":"query"},"name":"ImagesForPublic"},{"definition":{"arguments":[{"name":"email","type":"String!"},{"name":"password","type":"String!"}],"handler":"http://actions-backend.api:3000/signin","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"output_type":"SignInOutput","request_transform":{"method":"POST","query_params":{},"template_engine":"Kriti","version":2},"type":"query"},"name":"SignIn"},{"definition":{"arguments":[{"name":"token","type":"String!"},{"name":"image_id","type":"uuid!"},{"name":"status","type":"String!"}],"handler":"http://actions-backend.api:3000/images","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"kind":"synchronous","output_type":"UpdateImageStatusByTokenOutput","request_transform":{"method":"PUT","query_params":{"jwt":"{{$body.input.token}}"},"template_engine":"Kriti","version":2},"type":"mutation"},"name":"UpdateImageStatusByToken"},{"comment":"addAuthor","definition":{"arguments":[{"name":"CurrencyInfo","type":"InputParams!"}],"handler":"http://actions-backend.api:3000/author","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"output_type":"ConvertedCurrency","request_transform":{"body":{"action":"transform","template":"{\n  \"users\": {\n    \"from\": {{$body.input.CurrencyInfo.from}},\n    \"to\": {{$body.input.CurrencyInfo.to}},\n    \"amt\": {{$body.input.CurrencyInfo.amt}}\n  }\n}"},"method":"GET","query_params":{},"request_headers":{"add_headers":{},"remove_headers":["content-type"]},"template_engine":"Kriti","version":2},"type":"query"},"name":"currencyConverter"},{"comment":"generatePasswordHash","definition":{"arguments":[{"name":"arg1","type":"InputParams"}],"handler":"http://actions-backend.api:3000/md5","ignored_client_headers":["Content-Length","Content-MD5","User-Agent","Host","Origin","Referer","Accept","Accept-Encoding","Accept-Language","Accept-Datetime","Cache-Control","Connection","DNT","Content-Type"],"output_type":"HashedPassword","request_transform":{"body":{"action":"transform","template":"{\n  \"password\": {{$body.input.arg1.password}}\n}"},"method":"POST","query_params":{},"template_engine":"Kriti","version":2},"type":"query"},"name":"generatePasswordHash"}],"backend_configs":{"dataconnector":{"athena":{"uri":"http://data-connector-agent:8081/api/v1/athena"},"mariadb":{"uri":"http://data-connector-agent:8081/api/v1/mariadb"},"mysql8":{"uri":"http://data-connector-agent:8081/api/v1/mysql"},"oracle":{"uri":"http://data-connector-agent:8081/api/v1/oracle"},"snowflake":{"uri":"http://data-connector-agent:8081/api/v1/snowflake"}}},"custom_types":{"input_objects":[{"fields":[{"name":"email","type":"String!"},{"name":"role","type":"String!"}],"name":"SampleInput"},{"fields":[{"name":"password","type":"String"}],"name":"InputParams"}],"objects":[{"fields":[{"name":"collection_id","type":"uuid!"}],"name":"SampleOutput"},{"fields":[{"name":"rate","type":"Float"}],"name":"Info"},{"fields":[{"name":"amount","type":"Int"},{"name":"from","type":"String"},{"name":"to","type":"String"}],"name":"Query"},{"fields":[{"name":"date","type":"String"},{"name":"info","type":"Info"},{"name":"query","type":"Query"},{"name":"result","type":"Float"},{"name":"success","type":"Boolean"}],"name":"ConvertedCurrency"},{"fields":[{"name":"hash","type":"String"}],"name":"HashedPassword"},{"fields":[{"name":"user_id","type":"uuid!"}],"name":"AddUserOutput"},{"fields":[{"name":"role","type":"String!"},{"name":"user_id","type":"uuid!"}],"name":"AddRoleOutput"},{"fields":[{"name":"jwt","type":"String!"}],"name":"SignInOutput"},{"fields":[{"name":"collection_id","type":"uuid!"}],"name":"AddCollectionOutput"},{"fields":[{"name":"role","type":"String!"},{"name":"user_id","type":"uuid!"}],"name":"AddAuthorByTokenOutput"},{"fields":[{"name":"collection_id","type":"uuid!"},{"name":"user_id","type":"uuid!"}],"name":"AddAuthorToCollectionByTokenOutput"},{"fields":[{"name":"image_id","type":"uuid!"},{"name":"url","type":"String!"}],"name":"AddImageByTokenOutput"},{"fields":[{"name":"image_id","type":"uuid!"},{"name":"status","type":"String!"}],"name":"UpdateImageStatusByTokenOutput"},{"fields":[{"name":"url","type":"String!"}],"name":"File"},{"fields":[{"name":"tag_id","type":"uuid!"},{"name":"image_id","type":"uuid!"}],"name":"AddTagsToImageByTokenOutput"},{"fields":[{"name":"collection_id","type":"uuid!"},{"name":"image_id","type":"uuid!"}],"name":"AddImageVsCollectionRelationMutationOutput"},{"fields":[{"name":"image_id","type":"uuid!"},{"name":"status","type":"String!"},{"name":"url","type":"String!"},{"name":"user_id","type":"uuid!"}],"name":"ImagesForPublicOutput"}],"scalars":[{"name":"Upload"}]},"sources":[{"configuration":{"connection_info":{"database_url":{"from_env":"PG_DATABASE_URL"},"isolation_level":"read-committed","use_prepared_statements":false}},"kind":"postgres","logical_models":[{"fields":[{"name":"image_id","type":{"nullable":false,"scalar":"uuid"}},{"name":"url","type":{"nullable":false,"scalar":"text"}},{"name":"created_at","type":{"nullable":false,"scalar":"timestamptz"}},{"name":"status","type":{"nullable":false,"scalar":"text"}},{"name":"user_id","type":{"nullable":false,"scalar":"uuid"}}],"name":"Images"},{"fields":[{"name":"image_id","type":{"nullable":false,"scalar":"uuid"}},{"name":"url","type":{"nullable":false,"scalar":"text"}},{"name":"created_at","type":{"nullable":false,"scalar":"timestamptz"}},{"name":"status","type":{"nullable":false,"scalar":"text"}},{"name":"tags","type":{"nullable":false,"scalar":"text"}},{"name":"collections","type":{"array":{"nullable":false,"scalar":"uuid"},"nullable":false}}],"name":"ImagesExV3"},{"fields":[{"name":"image_id","type":{"nullable":false,"scalar":"uuid"}},{"name":"created_at","type":{"nullable":false,"scalar":"timestamptz"}},{"name":"status","type":{"nullable":false,"scalar":"text"}},{"name":"url","type":{"nullable":false,"scalar":"text"}},{"name":"user_id","type":{"nullable":false,"scalar":"uuid"}},{"name":"tags","type":{"nullable":false,"scalar":"text"}},{"name":"collections","type":{"nullable":false,"scalar":"text"}}],"name":"ImagesExtended"},{"fields":[{"name":"image_id","type":{"nullable":false,"scalar":"uuid"}},{"name":"url","type":{"nullable":false,"scalar":"text"}},{"name":"created_at","type":{"nullable":false,"scalar":"timestamptz"}},{"name":"status","type":{"nullable":false,"scalar":"text"}},{"name":"tags","type":{"array":{"nullable":false,"scalar":"text"},"nullable":false}},{"name":"collections","type":{"array":{"nullable":false,"scalar":"text"},"nullable":false}}],"name":"ImagesExtenedV2"}],"name":"Local","native_queries":[{"arguments":{"search_tag":{"description":"","nullable":false,"type":"text"}},"code":"SELECT image_id, url, created_at, status, user_id, tags, collections FROM (\n    SELECT i.image_id, i.url, i.created_at, i.status, i.user_id, string_agg(DISTINCT t.name, '','') as tags, string_agg(DISTINCT c.collection_name, '','') as collections\n    FROM public.tags t\n    INNER JOIN public.tags_vs_images tvi ON t.tag_id=tvi.tag_id\n    INNER JOIN public.images i ON tvi.image_id=i.image_id\n    LEFT JOIN public.collections_vs_images cvi ON i.image_id=cvi.image_id\n    LEFT JOIN public.collections c ON cvi.collection_id=c.collection_id\n    GROUP BY i.image_id\n) tmp\nWHERE lower(tags) similar to (''%'' || {{search_tag}} || ''%'')","returns":"ImagesExtended","root_field_name":"ImagesByTagsInCollections"},{"arguments":{"user_id":{"description":"","nullable":false,"type":"uuid"}},"code":"SELECT iii.image_id, iii.url, iii.created_at, iii.status, iii.user_id, 2 as prio\nFROM public.images iii\nUNION\nSELECT i.image_id, i.url, i.created_at, i.status, i.user_id, 0 as prio\nFROM public.images i \nWHERE i.user_id={{user_id}}\nUNION \nSELECT ii.image_id, ii.url, ii.created_at, ii.status, ii.user_id, 1 as prio\nFROM public.collections_vs_authors cva \nINNER JOIN public.collections_vs_images cvi ON cva.collection_id=cvi.collection_id\nINNER JOIN public.images ii ON ii.image_id=cvi.image_id\nWHERE cva.user_id={{user_id}}\nORDER BY prio asc, created_at desc","returns":"Images","root_field_name":"ImagesForTheAuthorInCorrectOrder"}],"tables":[{"array_relationships":[{"name":"collections_vs_authors","using":{"foreign_key_constraint_on":{"column":"collection_id","table":{"name":"collections_vs_authors","schema":"public"}}}}],"table":{"name":"collections","schema":"public"}},{"object_relationships":[{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"table":{"name":"collections_vs_authors","schema":"public"}},{"delete_permissions":[{"comment":"","permission":{"filter":{"_and":[{"image":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"collection":{"collections_vs_authors":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"role":"author"}],"insert_permissions":[{"comment":"","permission":{"check":{"_and":[{"image":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"collection":{"collections_vs_authors":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]},"columns":["collection_id","image_id"]},"role":"author"}],"object_relationships":[{"name":"collection","using":{"foreign_key_constraint_on":"collection_id"}},{"name":"image","using":{"foreign_key_constraint_on":"image_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["collection_id","image_id"],"filter":{"_and":[{"image":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"collection":{"collections_vs_authors":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}]}},"role":"author"}],"table":{"name":"collections_vs_images","schema":"public"}},{"array_relationships":[{"name":"collections_vs_images","using":{"foreign_key_constraint_on":{"column":"image_id","table":{"name":"collections_vs_images","schema":"public"}}}},{"name":"tags_vs_images","using":{"foreign_key_constraint_on":{"column":"image_id","table":{"name":"tags_vs_images","schema":"public"}}}}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["image_id","url","user_id"]},"role":"author"}],"object_relationships":[{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["image_id","status","url"],"filter":{}},"role":"author"},{"comment":"","permission":{"columns":["status","url","created_at","image_id","user_id"],"filter":{}},"role":"public"}],"table":{"name":"images","schema":"public"},"update_permissions":[{"comment":"","permission":{"check":null,"columns":["status"],"filter":{"user_id":{"_eq":"X-Hasura-User-Id"}}},"role":"author"}]},{"array_relationships":[{"name":"tags_vs_images","using":{"foreign_key_constraint_on":{"column":"tag_id","table":{"name":"tags_vs_images","schema":"public"}}}}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["name"]},"role":"author"}],"select_permissions":[{"comment":"","permission":{"columns":["tag_id"],"filter":{}},"role":"author"}],"table":{"name":"tags","schema":"public"}},{"insert_permissions":[{"comment":"","permission":{"check":{"_or":[{"image":{"user_id":{"_eq":"X-Hasura-User-Id"}}},{"image":{"collections_vs_images":{"collection":{"collections_vs_authors":{"user_id":{"_eq":"X-Hasura-User-Id"}}}}}}]},"columns":["image_id","tag_id"]},"role":"author"}],"object_relationships":[{"name":"image","using":{"foreign_key_constraint_on":"image_id"}},{"name":"tag","using":{"foreign_key_constraint_on":"tag_id"}}],"select_permissions":[{"comment":"","permission":{"columns":["image_id","tag_id"],"filter":{}},"role":"author"}],"table":{"name":"tags_vs_images","schema":"public"}},{"array_relationships":[{"name":"users_vs_roles","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"users_vs_roles","schema":"public"}}}}],"insert_permissions":[{"comment":"","permission":{"check":{},"columns":["email","password","user_id"]},"role":"public"}],"select_permissions":[{"comment":"","permission":{"columns":["email","password","user_id"],"filter":{},"limit":1},"role":"public"}],"table":{"name":"users","schema":"public"}},{"object_relationships":[{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"select_permissions":[{"comment":"","permission":{"columns":[],"filter":{"user_id":{"_eq":"X-Hasura-User-Id"}}},"role":"author"},{"comment":"","permission":{"columns":["role","user_id"],"filter":{},"limit":1},"role":"public"}],"table":{"name":"users_vs_roles","schema":"public"}}]}],"version":3}', 163);


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--



--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--



--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

INSERT INTO hdb_catalog.hdb_schema_notifications VALUES (1, '{"metadata":false,"remote_schemas":[],"sources":[],"data_connectors":[]}', 163, '8c604dfb-85f8-4c05-8835-c9ef161135ff', '2024-12-19 09:31:20.179979+00');


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

INSERT INTO hdb_catalog.hdb_version VALUES ('8a633af5-0d1b-4261-9d42-9cc3aff2781b', '48', '2024-12-19 09:30:00.270062+00', '{}', '{"console_notifications": {"admin": {"date": "2024-12-20T13:51:05.523Z", "read": [], "showBadge": false}}}', NULL, NULL);


--
-- Data for Name: collections; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.collections VALUES ('97559eab-17ff-4537-bf83-478702811dfe', 'testCollection5');
INSERT INTO public.collections VALUES ('111e3a90-6cc6-4c8a-87c8-9df1126a8574', 'first collection');


--
-- Data for Name: collections_vs_authors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.collections_vs_authors VALUES ('97559eab-17ff-4537-bf83-478702811dfe', '915c7781-aa35-4cd2-b7f5-970309db8af3');
INSERT INTO public.collections_vs_authors VALUES ('111e3a90-6cc6-4c8a-87c8-9df1126a8574', 'ed615421-4316-45d4-8c95-0f11d6f31539');


--
-- Data for Name: collections_vs_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.collections_vs_images VALUES ('97559eab-17ff-4537-bf83-478702811dfe', '4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc');
INSERT INTO public.collections_vs_images VALUES ('111e3a90-6cc6-4c8a-87c8-9df1126a8574', '38b16e72-5f61-4f85-8570-562236ab0fa7');
INSERT INTO public.collections_vs_images VALUES ('111e3a90-6cc6-4c8a-87c8-9df1126a8574', 'f8c0de83-3a9c-4a49-8823-1d3d64c7a631');


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.images VALUES ('983d3cb5-cc43-4209-a28a-7790cd147c8e', 'test_url', '2024-12-23 13:43:16.871959+00', 'unchecked', '58115f99-72fa-4ad8-a2b1-dbc6d9120f4e');
INSERT INTO public.images VALUES ('f8c0de83-3a9c-4a49-8823-1d3d64c7a631', 'testurl', '2024-12-23 13:53:40.444636+00', 'unchecked', '58115f99-72fa-4ad8-a2b1-dbc6d9120f4e');
INSERT INTO public.images VALUES ('38b16e72-5f61-4f85-8570-562236ab0fa7', 'testurl2', '2024-12-23 14:11:59.798894+00', 'checked2', '58115f99-72fa-4ad8-a2b1-dbc6d9120f4e');
INSERT INTO public.images VALUES ('4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc', 'https://i.imgur.com/wXctydx.png', '2024-12-24 08:49:15.08051+00', 'unchecked', '58115f99-72fa-4ad8-a2b1-dbc6d9120f4e');
INSERT INTO public.images VALUES ('be56f57c-94ac-4866-9c59-a311a98be04c', 'https://i.imgur.com/vRBwV2I.png', '2024-12-24 13:57:07.839078+00', 'unchecked', 'ed615421-4316-45d4-8c95-0f11d6f31539');
INSERT INTO public.images VALUES ('d5394aea-167d-4fcc-9028-b46368c0f211', 'https://i.imgur.com/occOO49.png', '2024-12-24 13:58:42.228154+00', 'unchecked', 'ed615421-4316-45d4-8c95-0f11d6f31539');
INSERT INTO public.images VALUES ('ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73', 'https://my.custom.link/blabla.png', '2024-12-24 14:03:43.072854+00', 'checked', 'ed615421-4316-45d4-8c95-0f11d6f31539');


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tags VALUES ('25ba66b6-b0d3-4c18-affa-59f88c92a262', 'testtag');
INSERT INTO public.tags VALUES ('873a923d-937a-4e02-81da-4fde9640b323', 'testtag');
INSERT INTO public.tags VALUES ('a5bf91eb-0926-4bf0-824a-b1115043b092', 'super new tag');
INSERT INTO public.tags VALUES ('7701c52e-13e9-485b-ba9f-fe39e7e8446c', 'super new tag');
INSERT INTO public.tags VALUES ('54fafcb1-a8d0-4e80-8540-326b5de18625', 'super new tag');
INSERT INTO public.tags VALUES ('d8817196-0f10-4b32-9dbb-812786e7fba6', 'super new tag');
INSERT INTO public.tags VALUES ('c2adcb97-860b-458e-9ea2-3e45bc7991d7', 'super new tag');
INSERT INTO public.tags VALUES ('274eb1db-6000-4f6e-87dd-0411b0e20ea2', 'super new tag');
INSERT INTO public.tags VALUES ('2afafc9a-4a1e-4399-ac07-10bdac470ae8', 'super new tag');
INSERT INTO public.tags VALUES ('7b467278-d07b-4762-b9f0-6ae899e61d75', 'super new tag');


--
-- Data for Name: tags_vs_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tags_vs_images VALUES ('873a923d-937a-4e02-81da-4fde9640b323', '4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc');
INSERT INTO public.tags_vs_images VALUES ('54fafcb1-a8d0-4e80-8540-326b5de18625', '4b4774ed-1a4b-47d2-bcf5-8a49b879a8dc');
INSERT INTO public.tags_vs_images VALUES ('d8817196-0f10-4b32-9dbb-812786e7fba6', 'ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73');
INSERT INTO public.tags_vs_images VALUES ('c2adcb97-860b-458e-9ea2-3e45bc7991d7', '983d3cb5-cc43-4209-a28a-7790cd147c8e');
INSERT INTO public.tags_vs_images VALUES ('2afafc9a-4a1e-4399-ac07-10bdac470ae8', 'ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73');
INSERT INTO public.tags_vs_images VALUES ('7b467278-d07b-4762-b9f0-6ae899e61d75', 'ac5fc0fb-5fbf-43d7-b2ea-de1bbd326d73');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES ('53c54d70-1c4f-401e-8a79-cc4766613a46', 'test@test.com', 'privet');
INSERT INTO public.users VALUES ('838ed6bf-5aee-476f-a7f0-114e222fcd04', 'test1@test.com', '54b3f4bd6d43cc7216b7ff064af97926');
INSERT INTO public.users VALUES ('2d8529a8-3ef5-4191-84ce-fb6a996352b9', 'test2@test.com', '54b3f4bd6d43cc7216b7ff064af97926');
INSERT INTO public.users VALUES ('915c7781-aa35-4cd2-b7f5-970309db8af3', 'test4@test.com', 'be325db12178bafc7f0b7b65312e1341');
INSERT INTO public.users VALUES ('58115f99-72fa-4ad8-a2b1-dbc6d9120f4e', 'testauthor@gmail.com', 'be325db12178bafc7f0b7b65312e1341');
INSERT INTO public.users VALUES ('4048446f-b1f3-461d-9b31-7e1a9278b120', 'testauthor2@gmail.com', '3e2d46571fc99bcc3e73226e69ae133f');
INSERT INTO public.users VALUES ('c26b836e-5dc8-4f73-8a50-f2e764b500a4', 'admin@admin.com', '686a2e99fa71b75075ea1f6a95672a8c');
INSERT INTO public.users VALUES ('ed615421-4316-45d4-8c95-0f11d6f31539', 'author1@author.com', 'ad9bb2a3a77f320865e65d573ec41cc9');


--
-- Data for Name: users_vs_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users_vs_roles VALUES ('2d8529a8-3ef5-4191-84ce-fb6a996352b9', 'admin');
INSERT INTO public.users_vs_roles VALUES ('915c7781-aa35-4cd2-b7f5-970309db8af3', 'admin');
INSERT INTO public.users_vs_roles VALUES ('2d8529a8-3ef5-4191-84ce-fb6a996352b9', 'author');
INSERT INTO public.users_vs_roles VALUES ('58115f99-72fa-4ad8-a2b1-dbc6d9120f4e', 'author');
INSERT INTO public.users_vs_roles VALUES ('4048446f-b1f3-461d-9b31-7e1a9278b120', 'author');
INSERT INTO public.users_vs_roles VALUES ('c26b836e-5dc8-4f73-8a50-f2e764b500a4', 'admin');
INSERT INTO public.users_vs_roles VALUES ('ed615421-4316-45d4-8c95-0f11d6f31539', 'author');


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (collection_id);


--
-- Name: collections_vs_authors collections_vs_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections_vs_authors
    ADD CONSTRAINT collections_vs_authors_pkey PRIMARY KEY (collection_id, user_id);


--
-- Name: collections_vs_images collections_vs_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections_vs_images
    ADD CONSTRAINT collections_vs_images_pkey PRIMARY KEY (collection_id, image_id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (image_id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tag_id);


--
-- Name: tags_vs_images tags_vs_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_pkey PRIMARY KEY (tag_id);


--
-- Name: tags_vs_images tags_vs_images_tag_id_image_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_tag_id_image_id_key UNIQUE (tag_id, image_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users_vs_roles users_vs_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_vs_roles
    ADD CONSTRAINT users_vs_roles_pkey PRIMARY KEY (user_id, role);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX name_idx ON public.tags USING btree (name);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collections_vs_authors collections_vs_authors_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections_vs_authors
    ADD CONSTRAINT collections_vs_authors_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(collection_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: collections_vs_authors collections_vs_authors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections_vs_authors
    ADD CONSTRAINT collections_vs_authors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: collections_vs_images collections_vs_images_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections_vs_images
    ADD CONSTRAINT collections_vs_images_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(collection_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: collections_vs_images collections_vs_images_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections_vs_images
    ADD CONSTRAINT collections_vs_images_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.images(image_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: images images_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: tags_vs_images tags_vs_images_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.images(image_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: tags_vs_images tags_vs_images_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(tag_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: users_vs_roles users_vs_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_vs_roles
    ADD CONSTRAINT users_vs_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

