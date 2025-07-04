import { CustomerTypeService } from '../service/customer-type.service';
import { CustomerTypeDTO } from 'src/dataModel/customer-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class CustomerTypeController {
    private readonly customerTypeService;
    constructor(customerTypeService: CustomerTypeService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(customerTypeDTO: CustomerTypeDTO, req: any): Promise<any>;
    update(customerTypeDTO: CustomerTypeDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
    getCustomerType(req: any): Promise<any>;
}
