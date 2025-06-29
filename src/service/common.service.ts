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
            const result = await this.call_tracker.query(SQL.getVillageByCommuneID,[id]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async getGender() {
        try {
            const result = await this.call_tracker.query(SQL.getGender);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async getBusiness() {
        try {
            const result = await this.call_tracker.query(SQL.getBusiness);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}
