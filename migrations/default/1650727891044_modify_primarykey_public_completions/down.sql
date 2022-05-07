alter table "public"."completions" drop constraint "completions_pkey";
alter table "public"."completions"
    add constraint "completions_pkey1"
    primary key ("id");
