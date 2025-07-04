import { DeveloperService } from '../service/developer.service';
import { DeveloperDTO } from 'src/dataModel/developer.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class DeveloperController {
    private readonly developerService;
    constructor(developerService: DeveloperService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(developerDto: DeveloperDTO, req: any): Promise<any>;
    update(developerDto: DeveloperDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
