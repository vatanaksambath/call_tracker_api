import { DataSource } from 'typeorm';
import { PropertyProfileDTO } from 'src/dataModel/property-profile.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class PropertyProfileService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    PropertyProfilePagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createPropertyProfile(propertyProfileDTO: PropertyProfileDTO, userId: number): Promise<any>;
    updatePropertyProfile(propertyProfileDTO: PropertyProfileDTO, userId: number): Promise<any>;
    deletePropertyProfile(id: number | string): Promise<any>;
}
