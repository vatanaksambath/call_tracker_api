import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { PaymentService } from '../service/payment.service';
import { AuthGuard } from '../auth/auth.guard';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { PaymentDTO } from 'src/dataModel/payment.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('payment')
export class PaymentController {
    constructor(private readonly paymentService: PaymentService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_02')
    @UseGuards(AuthGuard)
    @Get('payment-schedule/:call_log_id')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Param('call_log_id') call_log_id: string) {
        try {
            const result = this.paymentService.generate_loan_schedule(call_log_id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_02')
    @UseGuards(AuthGuard)
    @Get('summary/:call_log_id')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async summary(@Param('call_log_id') call_log_id: string) {
       try {
            const result = this.paymentService.paymentSummary(call_log_id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_01')
    @UseGuards(AuthGuard)
    @Post('create')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() paymentDTO: PaymentDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.paymentService.createPayment(paymentDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_03')
    @UseGuards(AuthGuard)
    @Put('update')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() paymentDTO: PaymentDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.paymentService.updatePayment(paymentDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_04')
    @UseGuards(AuthGuard)
    @Delete(":id")
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Param('id') id: string | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.paymentService.deletePayment(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
