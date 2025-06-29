import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { CustomerTypeDTO } from 'src/dataModel/customer-type.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class CustomerTypeService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async CustomerTypePagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.customerTypePagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createCustomerType(customerTypeDTO: CustomerTypeDTO, userId: number) {
        const parameters = [customerTypeDTO.customer_type_name, customerTypeDTO.customer_type_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.customerTypeInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateCustomerType(customerTypeDTO: CustomerTypeDTO, userId: number) {
        const parameters = [customerTypeDTO.customer_type_id, customerTypeDTO.customer_type_name, customerTypeDTO.customer_type_description, customerTypeDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.customerTypeUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteCustomerType(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.customerTypeDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async getCustomerType() {
        try {
            const result = await this.call_tracker.query( SQL.getCustomerType);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}

