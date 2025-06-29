import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { CustomerTypeService } from '../service/customer-type.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { CustomerTypeDTO } from 'src/dataModel/customer-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('customer-type')
export class CustomerTypeController {
    constructor(private readonly customerTypeService: CustomerTypeService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_09', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.customerTypeService.CustomerTypePagination(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_09', 'PM_01')
    @UseGuards(AuthGuard)
    @Post('create')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() customerTypeDTO: CustomerTypeDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.customerTypeService.createCustomerType(customerTypeDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_09', 'PM_03')
    @UseGuards(AuthGuard)
    @Put('update')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() customerTypeDTO: CustomerTypeDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.customerTypeService.updateCustomerType(customerTypeDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_09', 'PM_04')
    @UseGuards(AuthGuard)
    @Delete(":id")
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Param('id') id: number | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.customerTypeService.deleteCustomerType(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @Get("/customer-type")
    @HttpCode(200)
    async getCustomerType(@Req() req) {
        try {
            const result = await this.customerTypeService.getCustomerType();
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
