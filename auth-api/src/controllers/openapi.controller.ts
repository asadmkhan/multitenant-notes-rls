import { Get, JsonController } from 'routing-controllers';
import { Service } from 'typedi';
import { openapi } from '../openapi';

@Service()
@JsonController()
export class OpenapiController {
  @Get('/openapi.json')
  spec() {
    return openapi;
  }
}
