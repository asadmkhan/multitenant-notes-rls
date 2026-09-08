import 'reflect-metadata';
import { createExpressServer, useContainer } from 'routing-controllers';
import { Container } from 'typedi';
import pinoHttp from 'pino-http';
import { loadConfig } from './config';
import { logger } from './logger';
import { HealthController } from './controllers/health.controller';

const config = loadConfig();

useContainer(Container);

const app = createExpressServer({
  controllers: [HealthController],
  validation: false,
  classTransformer: false,
});

app.use(pinoHttp({ logger }));

app.listen(config.PORT, () => {
  logger.info({ port: config.PORT }, 'auth-api listening');
});
