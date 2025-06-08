import {
    ExceptionFilter,
    Catch,
    ArgumentsHost,
    BadRequestException,
    HttpException,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
    catch(exception: HttpException, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const status = exception.getStatus();

        const exceptionResponse = exception.getResponse();
        let message = exception.message;

        if (
            exception instanceof BadRequestException &&
            typeof exceptionResponse === 'object' &&
            'message' in exceptionResponse &&
            Array.isArray(exceptionResponse['message']) && status===400
        ) {
            message = exceptionResponse['message'][0];
        } 

        if (status === 500) {
            const exceptionResponse = exception.getResponse();

            response.status(status).json((exceptionResponse as any).message);
        } else {
            response.status(status).json([{
                statusCode: status,
                error: exception.name,
                message,
            }]);
        }

     
    }
}

