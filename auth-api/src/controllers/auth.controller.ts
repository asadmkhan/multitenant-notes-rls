import { Body, JsonController, Post, UnauthorizedError } from 'routing-controllers';
import { Service } from 'typedi';
import { z } from 'zod';
import { ValidationError } from '../http-errors';
import { AuthService } from '../services/auth.service';

const loginBody = z.object({
  email: z.email().max(254),
  orgSlug: z
    .string()
    .min(1)
    .max(64)
    .regex(/^[a-z0-9-]+$/),
});

@Service()
@JsonController('/auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('/login')
  async login(@Body() body: unknown) {
    const parsed = loginBody.safeParse(body);
    if (!parsed.success) {
      throw new ValidationError(parsed.error.issues);
    }

    const result = await this.auth.login(parsed.data.email, parsed.data.orgSlug);
    if (!result) {
      throw new UnauthorizedError('unknown user or org');
    }

    return { tokenType: 'Bearer', ...result };
  }
}
