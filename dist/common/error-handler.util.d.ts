import { InternalServerErrorException } from '@nestjs/common';
export declare class ArrayBadRequestException extends InternalServerErrorException {
    constructor(nativeError: string);
}
export declare function dispatchBadRequestException(error: any): never;
