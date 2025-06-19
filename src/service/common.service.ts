import {  Injectable, UseGuards } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { formatAccountNumber } from 'src/common/common.util';

@Injectable()
export class CommonService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    // async appAcessPermission (userID: string , type:string ,isSpecail? : boolean) {
    //     const accessFunction   = await this.permissionService.getAppFunctionDynamic(); 
    //     const accessPermission = await this.permissionService.getAppFunctionPermission(); 
        
    //     const requiredAppFunIds =[ accessFunction[7], accessFunction[1] ]
    //     let allowedPermissions: any[];
    //     switch (type) {
    //         case 'READ':
    //             allowedPermissions = [
    //                 accessPermission[0].app_fun_per_id,
    //                 accessPermission[1].app_fun_per_id,
    //                 accessPermission[2].app_fun_per_id,
    //             ];
    //             break;
    //         case 'DELETE':
    //             allowedPermissions = [
    //                 accessPermission[0].app_fun_per_id,
    //                 accessPermission[3].app_fun_per_id,
    //             ];
    //             break;
    //         case 'EXPORT':
    //             allowedPermissions = [true];
    //             break;
    //         default:
    //             allowedPermissions = [
    //                 accessPermission[0].app_fun_per_id,
    //                 accessPermission[2].app_fun_per_id,
    //             ];
    //             break;
    //     }
    
    //     return this.permissionService.checkAccessAndPermission(
    //         userID,
    //         requiredAppFunIds,
    //         allowedPermissions,
    //     );
    // }

    async getProvince() {
        try {
            const result = await this.call_tracker.query( SQL.getProvince);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async getDistrictByProvinceID(id:number) {
        try {
            const result = await this.call_tracker.query( SQL.getDistrictByProviceID,[id]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async getCommuneByDistrictID(id:number) {
        try {
            const result = await this.call_tracker.query( SQL.getCommuneByDistrictID,[id]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async getVillageByCommuneID(id:number) {
        try {
            const result = await this.call_tracker.query( SQL.getVillageByCommuneID,[id]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}
