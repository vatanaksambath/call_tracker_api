import { DataSource } from 'typeorm';
import { StaffDTO } from 'src/dataModel/staff.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class StaffService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    StaffPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createStaff(staffDTO: StaffDTO, userId: number, menuId: string): Promise<any>;
    updateStaff(staffDTO: StaffDTO, userId: number, menuId: string): Promise<any>;
    deleteStaff(id: number | string): Promise<any>;
}
