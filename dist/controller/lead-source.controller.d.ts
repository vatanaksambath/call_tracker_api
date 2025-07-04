import { LeadSourceService } from '../service/lead-source.service';
import { LeadSourceDTO } from 'src/dataModel/lead-source.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class LeadSourceController {
    private readonly leadSourceService;
    constructor(leadSourceService: LeadSourceService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(leadSourceDTO: LeadSourceDTO, req: any): Promise<any>;
    update(leadSourceDTO: LeadSourceDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
    getCustomerType(req: any): Promise<any>;
}
