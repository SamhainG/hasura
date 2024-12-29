SET check_function_bodies = false;
CREATE TABLE public.collections (
    collection_id uuid DEFAULT gen_random_uuid() NOT NULL,
    collection_name text NOT NULL
);
CREATE TABLE public.collections_vs_authors (
    collection_id uuid NOT NULL,
    user_id uuid NOT NULL
);
CREATE TABLE public.collections_vs_images (
    collection_id uuid NOT NULL,
    image_id uuid NOT NULL
);
CREATE TABLE public.images (
    image_id uuid DEFAULT gen_random_uuid() NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT 'unchecked'::text NOT NULL,
    user_id uuid NOT NULL
);
CREATE TABLE public.tags (
    tag_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.tags_vs_images (
    tag_id uuid NOT NULL,
    image_id uuid NOT NULL
);
CREATE TABLE public.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password text NOT NULL
);
CREATE TABLE public.users_vs_roles (
    user_id uuid NOT NULL,
    role text NOT NULL
);
ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (collection_id);
ALTER TABLE ONLY public.collections_vs_authors
    ADD CONSTRAINT collections_vs_authors_pkey PRIMARY KEY (collection_id, user_id);
ALTER TABLE ONLY public.collections_vs_images
    ADD CONSTRAINT collections_vs_images_pkey PRIMARY KEY (collection_id, image_id);
ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (image_id);
ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tag_id);
ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_pkey PRIMARY KEY (tag_id);
ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_tag_id_image_id_key UNIQUE (tag_id, image_id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);
ALTER TABLE ONLY public.users_vs_roles
    ADD CONSTRAINT users_vs_roles_pkey PRIMARY KEY (user_id, role);
CREATE INDEX name_idx ON public.tags USING btree (name);
ALTER TABLE ONLY public.collections_vs_authors
    ADD CONSTRAINT collections_vs_authors_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(collection_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.collections_vs_authors
    ADD CONSTRAINT collections_vs_authors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.collections_vs_images
    ADD CONSTRAINT collections_vs_images_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(collection_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.collections_vs_images
    ADD CONSTRAINT collections_vs_images_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.images(image_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.images(image_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.tags_vs_images
    ADD CONSTRAINT tags_vs_images_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(tag_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.users_vs_roles
    ADD CONSTRAINT users_vs_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
