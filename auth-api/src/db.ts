import { Pool } from 'pg';
import { Service } from 'typedi';
import { loadConfig } from './config';

@Service()
export class Db {
  readonly pool: Pool;

  constructor() {
    const config = loadConfig();
    this.pool = new Pool({ connectionString: config.DATABASE_URL, max: 5 });
  }
}
