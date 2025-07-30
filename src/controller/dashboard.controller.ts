import { Controller, Post, Body, Get, Delete, Put, Param, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException, HttpCode } from '@nestjs/common';
import { DashboardService } from '../service/dashboard.service';
import { AuthGuard } from '../auth/auth.guard';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';

@Controller('dashboard')
export class DashboardController {
    constructor(private readonly dashboardService: DashboardService) { }

    @UseGuards(PermissionGuard)
    @RequirePermission('MU_01', 'PM_02')
    @UseGuards(AuthGuard)
    @Get('summary')
    @UsePipes(new ValidationPipe())
    @HttpCode(200)
    async sunnary(@Req() req) {
        const userId = req.user?.user_id;
       try {
            const result = this.dashboardService.DashboardSummary(userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}
