import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { BusinessDTO } from 'src/dataModel/business.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class BusinessService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async BusinessPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.businessPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createBusiness(businessDTO: BusinessDTO, userId: number) {
        const parameters = [businessDTO.business_name, businessDTO.business_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.businessInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateBusiness(businessDTO: BusinessDTO, userId: number) {
        const parameters = [businessDTO.business_id, businessDTO.business_name, businessDTO.business_description, businessDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.businessUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteBusiness(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.businessDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async getBsuiness() {
        try {
            const result = await this.call_tracker.query( SQL.getBusiness);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}

