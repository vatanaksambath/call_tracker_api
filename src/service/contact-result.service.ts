import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { ContactResultDTO } from 'src/dataModel/contact-result.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class ContactResultService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async ContactResultPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.menu_id, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.contactResultPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createContactResult(contactResultDTO: ContactResultDTO, userId: number) {
        const parameters = [
            contactResultDTO.menu_id,
            contactResultDTO.contact_result_name, 
            contactResultDTO.contact_result_description, 
            userId
        ];
        try {
            const result = await this.call_tracker.query(SQL.contactResultInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateContactResult(contactResultDTO: ContactResultDTO, userId: number) {
        const parameters = [
            contactResultDTO.menu_id,
            contactResultDTO.contact_result_id,
            contactResultDTO.contact_result_name,          
            contactResultDTO.contact_result_description, 
            contactResultDTO.is_active,
            userId
        ];
        try {
            const result = await this.call_tracker.query(SQL.contactResultUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteContactResult(id: number | string, userId: number) {
        try {
            const result = await this.call_tracker.query(SQL.contactResultDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

