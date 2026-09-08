import jwt from 'jsonwebtoken';
import { Service } from 'typedi';
import { loadConfig } from '../config';
import { Db } from '../db';
import { logger } from '../logger';
import { findUserByEmailAndOrg } from '../queries/users.queries';

const scopesByRole: Record<string, string[]> = {
  admin: ['notes:read', 'notes:write', 'notes:delete'],
  editor: ['notes:read', 'notes:write'],
};

export interface LoginResult {
  token: string;
  expiresIn: number;
}

@Service()
export class AuthService {
  private readonly config = loadConfig();

  constructor(private readonly db: Db) {}

  async login(email: string, orgSlug: string): Promise<LoginResult | null> {
    const [user] = await findUserByEmailAndOrg.run({ email, orgSlug }, this.db.pool);
    if (!user) {
      logger.warn({ orgSlug }, 'login failed, user not found');
      return null;
    }

    const token = jwt.sign(
      {
        org_id: user.org_id,
        role: user.role,
        scopes: scopesByRole[user.role] ?? [],
      },
      this.config.JWT_SECRET,
      {
        algorithm: 'HS256',
        subject: user.id,
        issuer: this.config.JWT_ISSUER,
        audience: this.config.JWT_AUDIENCE,
        expiresIn: this.config.JWT_TTL_SECONDS,
      },
    );

    logger.info({ userId: user.id, orgId: user.org_id, role: user.role }, 'login ok');
    return { token, expiresIn: this.config.JWT_TTL_SECONDS };
  }
}
