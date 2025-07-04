import { DataSource } from 'typeorm';
import { PropertyTypeDTO } from 'src/dataModel/property-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class PropertyTypeService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    PropertyTypePagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createPropertyType(propertyTypeDTO: PropertyTypeDTO, userId: number): Promise<any>;
    updatePropertyType(propertyTypeDTO: PropertyTypeDTO, userId: number): Promise<any>;
    deletePropertyType(id: number | string): Promise<any>;
}
