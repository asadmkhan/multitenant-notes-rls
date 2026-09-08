import 'reflect-metadata';
import { createExpressServer, useContainer } from 'routing-controllers';
import { Container } from 'typedi';
import pinoHttp from 'pino-http';
import { loadConfig } from './config';
import { logger } from './logger';
import { AuthController } from './controllers/auth.controller';
import { HealthController } from './controllers/health.controller';

const config = loadConfig();

useContainer(Container);

const app = createExpressServer({
  controllers: [AuthController, HealthController],
  validation: false,
  classTransformer: false,
  development: process.env.NODE_ENV !== 'production',
});

app.use(pinoHttp({ logger }));

app.listen(config.PORT, () => {
  logger.info({ port: config.PORT }, 'auth-api listening');
});
