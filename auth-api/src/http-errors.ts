import { HttpError } from 'routing-controllers';

export class ValidationError extends HttpError {
  constructor(public readonly errors: unknown) {
    super(400, 'invalid request body');
    this.name = 'ValidationError';
  }
}
