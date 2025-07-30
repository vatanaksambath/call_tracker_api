import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { PropertyProfileDTO } from 'src/dataModel/property-profile.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class PropertyProfileService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async PropertyProfilePagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId]
        try {
            const result = await this.call_tracker.query(SQL.propertyProfilePagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async PropertyProfileSummary(userId: number) {
        try {
            const result = await this.call_tracker.query(SQL.propertyProfileSummary, [userId]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createPropertyProfile(propertyProfileDTO: PropertyProfileDTO, userId: number) {
        const parameters = [
            propertyProfileDTO.property_type_id,
            propertyProfileDTO.project_id,
            propertyProfileDTO.project_owner_id,
            propertyProfileDTO.village_id,
            propertyProfileDTO.property_profile_name,
            propertyProfileDTO.home_number,
            propertyProfileDTO.room_number,
            propertyProfileDTO.address,
            propertyProfileDTO.width,
            propertyProfileDTO.length,
            propertyProfileDTO.price,
            propertyProfileDTO.bedroom,
            propertyProfileDTO.bathroom,
            propertyProfileDTO.year_built,       
            propertyProfileDTO.description,
            propertyProfileDTO.feature,
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.propertyProfileInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updatePropertyProfile(propertyProfileDTO: PropertyProfileDTO, userId: number) {
        const parameters = [
            propertyProfileDTO.property_profile_id,
            propertyProfileDTO.property_type_id,
            propertyProfileDTO.project_id,
            propertyProfileDTO.project_owner_id,
            propertyProfileDTO.village_id,
            propertyProfileDTO.property_profile_name,
            propertyProfileDTO.home_number,
            propertyProfileDTO.room_number,
            propertyProfileDTO.address,
            propertyProfileDTO.width,
            propertyProfileDTO.length,
            propertyProfileDTO.price,
            propertyProfileDTO.bedroom,
            propertyProfileDTO.bathroom,  
            propertyProfileDTO.year_built,     
            propertyProfileDTO.description,
            propertyProfileDTO.feature,
            propertyProfileDTO.is_active,
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.propertyProfileUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deletePropertyProfile(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.propertyProfileDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

