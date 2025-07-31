import {
    BadRequestException,
    Body,
    Controller,
    Delete,
    ForbiddenException,
    Get,
    HttpCode,
    Param,
    Post,
    Put,
    Query,
    Request,
    UseGuards,
} from '@nestjs/common'

import { AuthGuard } from "../auth/auth.guard";
import { CommonService } from '../service/common.service';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { RequirePermission } from 'src/auth/decorator/permission.decorator';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';

@Controller('common')
@UseGuards(AuthGuard)
export class CommonController {
    constructor(private readonly commonService: CommonService) { }
    
    // @UseGuards(PermissionGuard)
    // @RequirePermission('MU_02', 'PM_02')
    @Get("address/province")
    @HttpCode(200)
    async getProvince(@Request() req) {
        try {
            const result = await this.commonService.getProvince();
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @Get("address/district/:id")
    @HttpCode(200)
    async getDistrictByProvinceID(@Param('id') id: number,@Request() req) {
        try {
            const result = await this.commonService.getDistrictByProvinceID(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @Get("address/commune/:id")
    @HttpCode(200)
    async getCommuneByDistrictID(@Param('id') id: number,@Request() req) {
        try {
            const result = await this.commonService.getCommuneByDistrictID(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @Get("address/village/:id")
    @HttpCode(200)
    async getVillageByCommuneID(@Param('id') id: number,@Request() req) {
        try {
            const result = await this.commonService.getVillageByCommuneID(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

      // @RequirePermission('MU_02', 'PM_02')
    @Get("/gender")
    @HttpCode(200)
    async getGender(@Request() req) {
        try {
            const result = await this.commonService.getGender();
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @Get("/business")
    @HttpCode(200)
    async getBusiness(@Request() req) {
        try {
            const result = await this.commonService.getBusiness();
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }

    @Get("address/summary")
    @HttpCode(200)
    async summary(@Request() req) {
        try {
            const userId = req.user?.user_id;
            const result = await this.commonService.addressSummary(userId);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}