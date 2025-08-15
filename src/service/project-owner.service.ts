import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { ProjectOwnerDTO } from 'src/dataModel/project-owner.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class ProjectOwnerService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async projectOwnerPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.projectOwnerPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createProjectOwner(projectOwnerDTO: ProjectOwnerDTO, userId: number) {
        const parameters = [projectOwnerDTO.gender_id, projectOwnerDTO.village_id, projectOwnerDTO.first_name, projectOwnerDTO.last_name, projectOwnerDTO.date_of_birth, projectOwnerDTO.remark, userId]
        try {
            const result = await this.call_tracker.query(SQL.projectOwnerInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateProjectOwner(projectOwnerDTO: ProjectOwnerDTO, userId: number) {
        const parameters = [projectOwnerDTO.project_owner_id, projectOwnerDTO.gender_id, projectOwnerDTO.village_id, projectOwnerDTO.first_name, projectOwnerDTO.last_name, projectOwnerDTO.date_of_birth, projectOwnerDTO.remark, projectOwnerDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.projectOwnerUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteProjectOwner(id: number | string) {

        try {
            const result = await this.call_tracker.query(SQL.projectOwnerDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async exportProjectOwner(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.projectOwnerExport, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

}

