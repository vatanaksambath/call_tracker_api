import { StaffService } from '../service/staff.service';
import { StaffDTO } from 'src/dataModel/staff.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class StaffController {
    private readonly staffService;
    constructor(staffService: StaffService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(staffDTO: StaffDTO, req: any): Promise<any>;
    update(staffDTO: StaffDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
