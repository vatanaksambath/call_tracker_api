import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { PropertyStatusDTO } from 'src/dataModel/property-status.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class PropertyStatusService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async PropertyStatusPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.propertyStatusPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createPropertyStatus(propertyStatusDTO: PropertyStatusDTO, userId: number) {
        const parameters = [propertyStatusDTO.property_status_name, propertyStatusDTO.property_status_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.propertyStatusInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updatePropertyStatus(propertyStatusDTO: PropertyStatusDTO, userId: number) {
        const parameters = [propertyStatusDTO.property_status_id, propertyStatusDTO.property_status_name, propertyStatusDTO.property_status_description, userId];
        try {
            const result = await this.call_tracker.query(SQL.propertyStatusUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deletePropertyStatus(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.propertyStatusDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

