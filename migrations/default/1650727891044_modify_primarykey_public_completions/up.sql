BEGIN TRANSACTION;
ALTER TABLE "public"."completions" DROP CONSTRAINT "completions_pkey1";

ALTER TABLE "public"."completions"
    ADD CONSTRAINT "completions_pkey1" PRIMARY KEY ("prompt");
COMMIT TRANSACTION;
