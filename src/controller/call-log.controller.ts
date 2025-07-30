import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { CallLogService } from '../service/call-log.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { CallLogDTO } from 'src/dataModel/call-log.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('call-log')
export class CallLogController {
    constructor(private readonly CallLogService: CallLogService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.CallLogService.CallLogPagination(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_02')
    @UseGuards(AuthGuard)
    @Get('summary')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async summary(@Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.CallLogService.CallLogSummary(userId);
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
    async create(@Body() CallLogDTO: CallLogDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.CallLogService.createCallLog(CallLogDTO, userId, "MU_02");
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
    async update(@Body() CallLogDTO: CallLogDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.CallLogService.updateCallLog(CallLogDTO, userId, "MU_02");
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
    async delete(@Param('id') id: number | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.CallLogService.deleteCallLog(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
