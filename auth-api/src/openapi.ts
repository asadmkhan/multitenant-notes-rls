export const openapi = {
  openapi: '3.0.3',
  info: {
    title: 'auth-api',
    version: '0.1.0',
    description:
      'Login for the notes demo. Post an email and org slug, get a JWT back. Use that token in the postgrest spec (Authorize button, value "Bearer <token>").',
  },
  paths: {
    '/auth/login': {
      post: {
        summary: 'Log in and get a JWT',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'orgSlug'],
                properties: {
                  email: { type: 'string', format: 'email' },
                  orgSlug: { type: 'string', pattern: '^[a-z0-9-]+$' },
                },
              },
              examples: {
                editor: {
                  summary: 'julia, editor at nordwind',
                  value: { email: 'julia.brandt@nordwind-logistik.de', orgSlug: 'nordwind' },
                },
                admin: {
                  summary: 'weber, admin at nordwind',
                  value: { email: 'm.weber@nordwind-logistik.de', orgSlug: 'nordwind' },
                },
                otherOrg: {
                  summary: 'sarah, admin at pixelhaus',
                  value: { email: 'sarah@pixelhaus.io', orgSlug: 'pixelhaus' },
                },
              },
            },
          },
        },
        responses: {
          '200': {
            description: 'Token issued',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    tokenType: { type: 'string', example: 'Bearer' },
                    token: { type: 'string' },
                    expiresIn: { type: 'integer', example: 900 },
                  },
                },
              },
            },
          },
          '400': { description: 'Body failed validation' },
          '401': { description: 'No such user in that org' },
        },
      },
    },
    '/health': {
      get: {
        summary: 'Liveness check',
        responses: { '200': { description: 'ok' } },
      },
    },
  },
};
