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
import { CustomerPaginationDTO } from '../dataModel/common.dto';
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
            
            // const access = await this.commonService.appAcessPermission(req.user?.user_id,'READ',false)
            // if ( !access.status ) {
            //     throw new ForbiddenException(access.message);
            // }
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
            
            // const access = await this.commonService.appAcessPermission(req.user?.user_id,'READ',false)
            // if ( !access.status ) {
            //     throw new ForbiddenException(access.message);
            // }
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
            
            // const access = await this.commonService.appAcessPermission(req.user?.user_id,'READ',false)
            // if ( !access.status ) {
            //     throw new ForbiddenException(access.message);
            // }
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
            
            // const access = await this.commonService.appAcessPermission(req.user?.user_id,'READ',false)
            // if ( !access.status ) {
            //     throw new ForbiddenException(access.message);
            // }
            const result = await this.commonService.getVillageByCommuneID(id);
            return result;
        } catch (error) {
            dispatchBadRequestException(error);
        }
    }
}