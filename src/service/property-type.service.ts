import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { PropertyTypeDTO } from 'src/dataModel/property-type.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class PropertyTypeService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async PropertyTypePagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.propertyTypePagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createPropertyType(propertyTypeDTO: PropertyTypeDTO, userId: number) {
        const parameters = [propertyTypeDTO.property_type_name, propertyTypeDTO.property_type_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.propertyTypeInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updatePropertyType(propertyTypeDTO: PropertyTypeDTO, userId: number) {
        const parameters = [propertyTypeDTO.property_type_id, propertyTypeDTO.property_type_name, propertyTypeDTO.property_type_description, propertyTypeDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.propertyTypeUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deletePropertyType(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.propertyTypeDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

