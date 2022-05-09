alter table "public"."completions" add column "model" text
 not null default 'gpt3';
