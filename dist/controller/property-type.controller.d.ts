import { PropertyTypeService } from '../service/property-type.service';
import { PropertyTypeDTO } from 'src/dataModel/property-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class PropertyTypeController {
    private readonly propertyTypeService;
    constructor(propertyTypeService: PropertyTypeService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(PropertyTypeDTO: PropertyTypeDTO, req: any): Promise<any>;
    update(PropertyTypeDTO: PropertyTypeDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
