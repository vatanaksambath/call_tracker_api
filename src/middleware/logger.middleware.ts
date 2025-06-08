import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { formatDate } from '../common/common.util';
import { LoggingFormate } from '../common/logging.formate';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  constructor(
    private readonly logger: LoggingFormate,
    @InjectDataSource() private readonly call_tracker: DataSource,
  ) {}

  async intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<any>> {
    const req = context.switchToHttp().getRequest();
    const { method, originalUrl, user, ip, headers, body } = req;
    const userAgent = headers['user-agent'] || 'unknown';
    const start = Date.now();
    const requestTime = formatDate(new Date());

    this.logger.logRequest({ method, originalUrl, user, ip, userAgent, time: requestTime, body});
    try {
      await this.call_tracker.query(SQL.auditLogInsert, [
        method,
        originalUrl,
        user,
        ip,
        userAgent,
        null,
        null,
        null,
        null,
        'REQUEST',
        new Date(),
        body
      ]);
    } catch (err) {
      this.logger.logError({
        user,
        statusCode: 500,
        message: 'Failed to insert request log',
        duration: 0,
        time: requestTime,
        error: err?.message,
        userAgent,
        originalUrl,
        method,
      });
    }
    // // console.log(user);
    return next.handle().pipe(
      tap(async (response) => {
        const duration = Date.now() - start;
        const res = Array.isArray(response) ? response[0] : response;
        const statusCode = res?.statusCode ?? 200;
        const message = res?.message ?? 'Success';
        const errorMsg = res?.error ?? null;
        const now = formatDate(new Date());

        if (statusCode === 500 || errorMsg) {
          this.logger.logError({ user, statusCode, message, duration, time: now, error: errorMsg ?? 'Unknown', userAgent, originalUrl, method, body });
        } else {
          this.logger.logResponse({ user, statusCode, message, duration, time: now, userAgent, originalUrl, method, body });
        }

        try {
          await this.call_tracker.query(SQL.auditLogInsert, [
            method,
            originalUrl,
            user,
            ip,
            userAgent,
            statusCode,
            message,
            errorMsg,
            duration,
            'RESPONSE',
            new Date(),
            null
          ]);
        } catch (err) {
          this.logger.logError({
            user,
            statusCode: 500,
            message: 'Failed to insert response log',
            duration,
            time: now,
            error: err?.message,
            userAgent,
            originalUrl,
            method,
          });
        }
      }),
      catchError(async (err) => {
        const duration = Date.now() - start;
        const now = formatDate(new Date());
        const statusCode = err?.status ?? 500;
        const errorMsg = err?.message ?? 'Internal server error';

        this.logger.logError({ user, statusCode, message: errorMsg, duration, time: now, userAgent, originalUrl, method });

        try {
          await this.call_tracker.query(SQL.auditLogInsert, [
            method,
            originalUrl,
            user,
            ip,
            userAgent,
            statusCode,
            errorMsg,
            errorMsg,
            duration,
            'ERROR',
            new Date(),
            null
          ]);
        } catch (dbErr) {
          this.logger.logError({
            user,
            statusCode: 500,
            message: 'Failed to insert error log',
            duration,
            time: now,
            error: dbErr?.message,
            userAgent,
            originalUrl,
            method,
          });
        }
        throw err;
      }),
    );
  }
}