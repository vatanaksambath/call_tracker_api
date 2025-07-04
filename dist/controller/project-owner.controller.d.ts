import { ProjectOwnerService } from '../service/project-owner.service';
import { ProjectOwnerDTO } from 'src/dataModel/project-owner.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class ProjectOwnerController {
    private readonly projectOwnerService;
    constructor(projectOwnerService: ProjectOwnerService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(projectOwnerDto: ProjectOwnerDTO, req: any): Promise<any>;
    update(projectOwnerDto: ProjectOwnerDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
