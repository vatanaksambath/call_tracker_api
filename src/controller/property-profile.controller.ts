import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { PropertyProfileService } from '../service/property-profile.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { PropertyProfileDTO } from 'src/dataModel/property-profile.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('property-profile')
export class PropertyProfileController {
    constructor(private readonly propertyProfileService: PropertyProfileService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_06', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.propertyProfileService.PropertyProfilePagination(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_06', 'PM_01')
    @UseGuards(AuthGuard)
    @Post('create')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() propertyProfileDTO: PropertyProfileDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.propertyProfileService.createPropertyProfile(propertyProfileDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_06', 'PM_03')
    @UseGuards(AuthGuard)
    @Put('update')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() propertyProfileDTO: PropertyProfileDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.propertyProfileService.updatePropertyProfile(propertyProfileDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_06', 'PM_04')
    @UseGuards(AuthGuard)
    @Delete(":id")
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Param('id') id: number | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.propertyProfileService.deletePropertyProfile(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
