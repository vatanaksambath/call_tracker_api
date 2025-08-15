import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { DeveloperService } from '../service/developer.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { DeveloperDTO } from 'src/dataModel/developer.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('developer')
export class DeveloperController {
    constructor(private readonly developerService: DeveloperService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_12', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.developerService.developerPagination(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_12', 'PM_02')
    @UseGuards(AuthGuard)
    @Get('summary')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async summary(@Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.developerService.developerSummary(userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_12', 'PM_01')
    @UseGuards(AuthGuard)
    @Post('create')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() developerDto: DeveloperDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.developerService.createDeveloper(developerDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_12', 'PM_03')
    @UseGuards(AuthGuard)
    @Put('update')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() developerDto: DeveloperDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.developerService.updateDeveloper(developerDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_12', 'PM_04')
    @UseGuards(AuthGuard)
    @Delete(":id")
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Param('id') id: number | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.developerService.deleteDeveloper(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

     @UseGuards(PermissionGuard)
    @RequirePermission('MU_12', 'PM_05')
    @UseGuards(AuthGuard)
    @Post('export')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async export(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.developerService.developerExport(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
