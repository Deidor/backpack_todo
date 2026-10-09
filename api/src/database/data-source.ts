import 'dotenv/config';
import { DataSource } from 'typeorm';
import { Item } from '../items/item.entity';

export default new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  ssl:
    process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
  entities: [Item],
  migrations: [__dirname + '/migrations/*{.ts,.js}'],
});
