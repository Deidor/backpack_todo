import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import * as Joi from 'joi';
import { Item } from './items/item.entity';
import { ItemsModule } from './items/items.module';
import { join } from 'node:path';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        PORT: Joi.number().port().default(3000),
        DATABASE_URL: Joi.string().uri().required(),
        DATABASE_SSL: Joi.boolean().default(false),
      }),
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres' as const,
        url: config.getOrThrow<string>('DATABASE_URL'),
        ssl: config.get<boolean>('DATABASE_SSL')
          ? { rejectUnauthorized: false }
          : false,
        entities: [Item],
        // Applies pending migrations on startup, so a fresh database is
        // ready without a manual step.
        migrations: [join(__dirname, 'database/migrations/*.js')],
        migrationsRun: true,
      }),
    }),
    ItemsModule,
  ],
})
export class AppModule {}
