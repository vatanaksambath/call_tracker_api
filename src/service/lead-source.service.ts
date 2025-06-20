import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { LeadSourceDTO } from 'src/dataModel/lead-source.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class LeadSourceService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async LeadSourcePagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.leadSourcePagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createLeadSoruce(leadSourceDTO: LeadSourceDTO, userId: number) {
        const parameters = [leadSourceDTO.lead_source_name, leadSourceDTO.lead_source_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.leadSourceInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateLeadSoruce(leadSourceDTO: LeadSourceDTO, userId: number) {
        const parameters = [leadSourceDTO.lead_source_id, leadSourceDTO.lead_source_name, leadSourceDTO.lead_source_description, leadSourceDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.leadSourceUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteLeadSoruce(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.leadSourceDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

