import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { ChannelTypeService } from '../service/channel-type.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { ChannelTypeDTO } from 'src/dataModel/channel-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('channel-type')
export class ChannelTypeController {
    constructor(private readonly channelTypeService: ChannelTypeService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_16', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.channelTypeService.ChannelTypePagination(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_16', 'PM_01')
    @UseGuards(AuthGuard)
    @Post('create')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() ChannelTypeDTO: ChannelTypeDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.channelTypeService.createChannelType(ChannelTypeDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_16', 'PM_03')
    @UseGuards(AuthGuard)
    @Put('update')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() ChannelTypeDTO: ChannelTypeDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.channelTypeService.updateChannelType(ChannelTypeDTO, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_16', 'PM_04')
    @UseGuards(AuthGuard)
    @Delete(":id")
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Param('id') id: number | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.channelTypeService.deleteChannelType(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @Get("/channel-type")
    @HttpCode(200)
    async getCustomerType(@Req() req) {
        try {
            const result = await this.channelTypeService.getChannelType();
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
