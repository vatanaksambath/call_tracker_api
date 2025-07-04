import { LeadService } from '../service/lead.service';
import { LeadDTO } from 'src/dataModel/lead.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class LeadController {
    private readonly leadService;
    constructor(leadService: LeadService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(LeadDTO: LeadDTO, req: any): Promise<any>;
    update(LeadDTO: LeadDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
