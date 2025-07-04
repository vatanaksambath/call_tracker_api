import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { LeadDTO } from 'src/dataModel/lead.dto';
import { CommonDTO } from 'src/dataModel/common.dto';

@Injectable()
export class LeadService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async LeadPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId];
        try {
            const result = await this.call_tracker.query(SQL.leadPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createLead(leadDTO: LeadDTO, userId: number, menuId: string) {
        const parameters = [
            leadDTO.gender_id,
            leadDTO.customer_type_id,
            leadDTO.lead_source_id,
            leadDTO.village_id,
            leadDTO.business_id,
            leadDTO.initial_staff_id,
            leadDTO.current_staff_id,
            leadDTO.first_name,
            leadDTO.last_name,
            leadDTO.date_of_birth,
            leadDTO.email,
            leadDTO.occupation,
            leadDTO.home_address,
            leadDTO.street_address,
            leadDTO.biz_description,
            leadDTO.relationship_date,
            leadDTO.remark,
            leadDTO.photo_url,
            menuId,
            JSON.stringify(leadDTO.contact_data),
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.leadInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateLead(leadDTO: LeadDTO, userId: number, menuId: string) {
        const parameters = [
            leadDTO.lead_id,
            leadDTO.gender_id,
            leadDTO.customer_type_id,
            leadDTO.lead_source_id,
            leadDTO.village_id,
            leadDTO.business_id,
            leadDTO.initial_staff_id,
            leadDTO.current_staff_id,
            leadDTO.first_name,
            leadDTO.last_name,
            leadDTO.date_of_birth,
            leadDTO.email,
            leadDTO.occupation,
            leadDTO.home_address,
            leadDTO.street_address,
            leadDTO.biz_description,
            leadDTO.relationship_date,
            leadDTO.remark,
            leadDTO.photo_url,
            leadDTO.is_active,
            menuId,
            JSON.stringify(leadDTO.contact_data),
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.leadUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteLead(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.leadDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

