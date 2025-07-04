import { BusinessService } from '../service/business.service';
import { BusinessDTO } from 'src/dataModel/business.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class BusinessController {
    private readonly businessService;
    constructor(businessService: BusinessService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(businessDTO: BusinessDTO, req: any): Promise<any>;
    update(businessDTO: BusinessDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
