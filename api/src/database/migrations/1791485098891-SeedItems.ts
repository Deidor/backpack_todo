import { MigrationInterface, QueryRunner } from 'typeorm';

export class SeedItems1791485098891 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `INSERT INTO "items" ("name", "packed", "to_buy") VALUES
            ('Palos', true, false),
            ('Crema solar', false, true),
            ('Compostela', true, false),
            ('Gorro', true, false),
            ('Chubasquero', true, false),
            ('Chanclas', false, true)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DELETE FROM "items" WHERE "name" IN
            ('Palos', 'Crema solar', 'Compostela', 'Gorro', 'Chubasquero', 'Chanclas')`,
    );
  }
}
