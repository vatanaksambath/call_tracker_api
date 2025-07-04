import { DataSource } from 'typeorm';
import { LeadSourceDTO } from 'src/dataModel/lead-source.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class LeadSourceService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    LeadSourcePagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createLeadSoruce(leadSourceDTO: LeadSourceDTO, userId: number): Promise<any>;
    updateLeadSoruce(leadSourceDTO: LeadSourceDTO, userId: number): Promise<any>;
    deleteLeadSoruce(id: number | string): Promise<any>;
    getLeadSource(): Promise<any>;
}
