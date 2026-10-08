import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateItems1791484679134 implements MigrationInterface {
    name = 'CreateItems1791484679134'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "items" ("id" SERIAL NOT NULL, "name" character varying(60) NOT NULL, "packed" boolean NOT NULL DEFAULT false, "to_buy" boolean NOT NULL DEFAULT false, "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), CONSTRAINT "PK_ba5885359424c15ca6b9e79bcf6" PRIMARY KEY ("id"))`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "items"`);
    }

}
