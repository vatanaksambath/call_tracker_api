import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { ProjectDTO } from 'src/dataModel/project.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class ProjectService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async projectPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.projectPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createProject(projectDTO: ProjectDTO, userId: number) {
        const parameters = [projectDTO.developer_id, projectDTO.village_id, projectDTO.project_name, projectDTO.project_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.projectInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateProject(projectDTO: ProjectDTO, userId: number) {
        const parameters = [projectDTO.project_id, projectDTO.developer_id, projectDTO.village_id, projectDTO.project_name, projectDTO.project_description, projectDTO.is_active, userId]
        try {
            const result = await this.call_tracker.query(SQL.projectUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteProject(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.projectDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

