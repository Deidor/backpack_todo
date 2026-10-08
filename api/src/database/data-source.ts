import 'dotenv/config';
import { DataSource } from 'typeorm';
import { Item } from '../items/item.entity';

export default new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: [Item],
  migrations: [__dirname + '/migrations/*{.ts,.js}'],
});