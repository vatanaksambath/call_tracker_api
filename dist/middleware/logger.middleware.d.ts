import { NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { LoggingFormate } from '../common/logging.formate';
import { DataSource } from 'typeorm';
export declare class LoggingInterceptor implements NestInterceptor {
    private readonly logger;
    private readonly call_tracker;
    constructor(logger: LoggingFormate, call_tracker: DataSource);
    intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<any>>;
}
