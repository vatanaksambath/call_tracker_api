import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { ProjectService } from '../service/project.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { ProjectDTO } from 'src/dataModel/project.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('project')
export class ProjectController {
    constructor(private readonly projectService: ProjectService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_10', 'PM_02')
    @UseGuards(AuthGuard)
    @Post('pagination')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async get(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.projectService.projectPagination(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_10', 'PM_02')
    @UseGuards(AuthGuard)
    @Get('summary')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async summary(@Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.projectService.projectSummary(userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_10', 'PM_01')
    @UseGuards(AuthGuard)
    @Post('create')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() projectDto: ProjectDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.projectService.createProject(projectDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_10', 'PM_03')
    @UseGuards(AuthGuard)
    @Put('update')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() projectDto: ProjectDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.projectService.updateProject(projectDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_10', 'PM_04')
    @UseGuards(AuthGuard)
    @Delete(":id")
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Param('id') id: number | string, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.projectService.deleteProject(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_10', 'PM_05')
    @UseGuards(AuthGuard)
    @Post('export')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async export(@Body() commonDto: CommonDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.projectService.projectExport(commonDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
