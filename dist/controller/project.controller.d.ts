import { ProjectService } from '../service/project.service';
import { ProjectDTO } from 'src/dataModel/project.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class ProjectController {
    private readonly projectService;
    constructor(projectService: ProjectService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(projectDto: ProjectDTO, req: any): Promise<any>;
    update(projectDto: ProjectDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
