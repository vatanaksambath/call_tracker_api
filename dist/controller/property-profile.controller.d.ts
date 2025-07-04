import { PropertyProfileService } from '../service/property-profile.service';
import { PropertyProfileDTO } from 'src/dataModel/property-profile.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class PropertyProfileController {
    private readonly propertyProfileService;
    constructor(propertyProfileService: PropertyProfileService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(propertyProfileDTO: PropertyProfileDTO, req: any): Promise<any>;
    update(propertyProfileDTO: PropertyProfileDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
