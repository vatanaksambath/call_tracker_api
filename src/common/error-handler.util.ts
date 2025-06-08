import { InternalServerErrorException } from '@nestjs/common';

export class ArrayBadRequestException extends InternalServerErrorException {
  constructor(nativeError: string) {
    super([
      {
        message: 'Something went wrong, please try again.',
        error: nativeError,
        statusCode: 500,
      },
    ]);
  }
}

export function dispatchBadRequestException(error: any): never {
  const nativeError = error?.response?.message || error.message || 'Unknown error';
  throw new ArrayBadRequestException(nativeError);
}
