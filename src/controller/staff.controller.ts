import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { StaffService } from '../service/staff.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { StaffDTO } from 'src/dataModel/staff.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('staff')
export class StaffController {
    constructor(private readonly staffService: StaffService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_05', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.staffService.StaffPagination(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_05', 'PM_01')
    @UseGuards(AuthGuard)
    @Post('create')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() staffDTO: StaffDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.staffService.createStaff(staffDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_05', 'PM_03')
    @UseGuards(AuthGuard)
    @Put('update')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() staffDTO: StaffDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.staffService.updateStaff(staffDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_05', 'PM_04')
    @UseGuards(AuthGuard)
    @Delete(":id")
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Param('id') id: number | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.staffService.deleteStaff(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
