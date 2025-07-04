import { DataSource } from 'typeorm';
import { LeadDTO } from 'src/dataModel/lead.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class LeadService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    LeadPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createLead(leadDTO: LeadDTO, userId: number, menuId: string): Promise<any>;
    updateLead(leadDTO: LeadDTO, userId: number, menuId: string): Promise<any>;
    deleteLead(id: number | string): Promise<any>;
}
