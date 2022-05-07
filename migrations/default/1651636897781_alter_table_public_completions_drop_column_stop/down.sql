alter table "public"."completions" alter column "stop" drop not null;
alter table "public"."completions" add column "stop" _text;
