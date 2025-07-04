import { DataSource } from 'typeorm';
import { CustomerTypeDTO } from 'src/dataModel/customer-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class CustomerTypeService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    CustomerTypePagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createCustomerType(customerTypeDTO: CustomerTypeDTO, userId: number): Promise<any>;
    updateCustomerType(customerTypeDTO: CustomerTypeDTO, userId: number): Promise<any>;
    deleteCustomerType(id: number | string): Promise<any>;
    getCustomerType(): Promise<any>;
}
