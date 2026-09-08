import { Get, JsonController } from 'routing-controllers';
import { Service } from 'typedi';

@Service()
@JsonController()
export class HealthController {
  @Get('/health')
  health() {
    return { ok: true };
  }
}
