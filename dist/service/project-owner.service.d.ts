import { DataSource } from 'typeorm';
import { ProjectOwnerDTO } from 'src/dataModel/project-owner.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class ProjectOwnerService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    projectOwnerPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createProjectOwner(projectOwnerDTO: ProjectOwnerDTO, userId: number): Promise<any>;
    updateProjectOwner(projectOwnerDTO: ProjectOwnerDTO, userId: number): Promise<any>;
    deleteProjectOwner(id: number | string): Promise<any>;
}
