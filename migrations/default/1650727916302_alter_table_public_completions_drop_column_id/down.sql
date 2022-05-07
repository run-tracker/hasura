alter table "public"."completions" alter column "id" set default nextval('completions_id_seq'::regclass);
alter table "public"."completions" alter column "id" drop not null;
alter table "public"."completions" add column "id" int4;
