alter table "public"."completions" alter column "logprob" drop not null;
alter table "public"."completions" add column "logprob" numeric;
