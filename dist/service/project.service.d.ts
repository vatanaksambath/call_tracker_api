import { DataSource } from 'typeorm';
import { ProjectDTO } from 'src/dataModel/project.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class ProjectService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    projectPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createProject(projectDTO: ProjectDTO, userId: number): Promise<any>;
    updateProject(projectDTO: ProjectDTO, userId: number): Promise<any>;
    deleteProject(id: number | string): Promise<any>;
}
