import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { DeveloperDTO } from 'src/dataModel/developer.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class DeveloperService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async developerPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId]
        try {
            const result = await this.call_tracker.query(SQL.developerPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
    
    async developerSummary(userId: number) {
        try {
            const result = await this.call_tracker.query(SQL.developerSummary, [userId]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createDeveloper(developerDTO: DeveloperDTO, userId: number) {
        const parameters = [developerDTO.developer_name, developerDTO.developer_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.developerInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateDeveloper(developerDTO: DeveloperDTO, userId: number) {
        const parameters = [developerDTO.developer_id, developerDTO.developer_name, developerDTO.developer_description, developerDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.developerUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteDeveloper(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.developerDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

