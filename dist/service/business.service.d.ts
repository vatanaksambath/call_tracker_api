import { DataSource } from 'typeorm';
import { BusinessDTO } from 'src/dataModel/business.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class BusinessService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    BusinessPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createBusiness(businessDTO: BusinessDTO, userId: number): Promise<any>;
    updateBusiness(businessDTO: BusinessDTO, userId: number): Promise<any>;
    deleteBusiness(id: number | string): Promise<any>;
    getBsuiness(): Promise<any>;
}
