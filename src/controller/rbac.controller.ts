import { Controller, Post, Body, Get, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { RBACService } from '../service/rbac.service';
import { AuthGuard } from '../auth/auth.guard';
import { Request } from 'express';
import { RoleDTO } from 'src/dataModel/role.dto';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { UserRoleDTO } from 'src/dataModel/user-role.dto';

@Controller('rbac')
export class RBACController {
    constructor(private readonly rbacService: RBACService) { }

    @UseGuards(AuthGuard)
    @Get('get-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async getRole() {
       try {
            const result = this.rbacService.getRole();
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }


    @UseGuards(AuthGuard)
    @Post('create-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async create(@Body() roleDto: RoleDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.rbacService.createRole(roleDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(AuthGuard)
    @Post('update-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async update(@Body() roleDto: RoleDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.updateRole(roleDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(AuthGuard)
    @Post('delete-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async delete(@Body() roleDto: RoleDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.deleteRole(roleDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(AuthGuard)
    @Get('get-user-permission')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async getUserPermssion(@Req() req) {
        const userId = req.user?.user_id;
        console.log('User ID:', userId);
       try {
            const result = this.rbacService.getUserPermission(userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(AuthGuard)
    @Get('get-user-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async getUserRole() {
       try {
            const result = this.rbacService.getUserRole();
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(AuthGuard)
    @Post('create-user-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async createUserRole(@Body() userRoleDto: UserRoleDTO, @Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.rbacService.createUserRole(userRoleDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(AuthGuard)
    @Post('update-user-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async updateUserRole(@Body() userRoleDto: UserRoleDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.updateUserRole(userRoleDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @UseGuards(AuthGuard)
    @Post('delete-user-role')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async deleteUserRole(@Body() userRoleDto: UserRoleDTO, @Req() req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.deleteUserRole(userRoleDto, userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}