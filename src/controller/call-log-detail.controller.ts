import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { CallLogDetailService } from '../service/call-log-detail.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { CallLogDetailDTO } from 'src/dataModel/call-log-detail.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';
import { CommonDTO } from 'src/dataModel/common.dto';

@Controller('call-log-detail')
export class CallLogDetailController {
    constructor(private readonly callLogDetailService: CallLogDetailService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_02', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.callLogDetailService.CallLogDetailPagination(commonDto, userId);
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
    async create(@Body() callLogDetailDTO: CallLogDetailDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.callLogDetailService.createCallLogDetail(callLogDetailDTO, userId, "MU_02");
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
    async update(@Body() callLogDetailDTO: CallLogDetailDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.callLogDetailService.updateCallLogDetail(callLogDetailDTO, userId, "MU_02");
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
        @RequirePermission('MU_02', 'PM_05')
        @UseGuards(AuthGuard)
        @Post('export')
        @UsePipes(new ValidationPipe())
        @HttpCode(200)
        async export(@Body() commonDto: CommonDTO) {
           try {
                const result = this.callLogDetailService.callLogDetailExport(commonDto);
                return result;
            } catch (error) {
                dispatchBadRequestException(error);
            }
        }
}
