const tseslint = require('typescript-eslint');

module.exports = tseslint.config(
  { ignores: ['dist/**', 'src/**/*.queries.ts'] },
  ...tseslint.configs.recommended,
);
