import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { StaffDTO } from 'src/dataModel/staff.dto';
import { CommonDTO } from 'src/dataModel/common.dto';

@Injectable()
export class StaffService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async StaffPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId];
        console.log("Parameters for staff pagination:", parameters);
        try {
            const result = await this.call_tracker.query(SQL.staffPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async StaffSummary(userId: number) {
        const parameters = [userId];
        try {
            const result = await this.call_tracker.query(SQL.staffSummary, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createStaff(staffDTO: StaffDTO, userId: number, menuId: string) {
        const parameters = [
            staffDTO.staff_id,
            staffDTO.staff_code,
            staffDTO.gender_id,
            staffDTO.village_id,
            staffDTO.manager_id,
            staffDTO.first_name,
            staffDTO.last_name,
            staffDTO.date_of_birth,
            staffDTO.position,
            staffDTO.department,
            staffDTO.employment_type,
            staffDTO.employment_start_date,
            staffDTO.employment_end_date,
            staffDTO.employment_level,
            staffDTO.current_address,
            staffDTO.home_address,
            staffDTO.street_address,
            staffDTO.photo_url,
            menuId,
            JSON.stringify(staffDTO.contact_data),
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.staffInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateStaff(staffDTO: StaffDTO, userId: number, menuId: string) {
        const parameters = [
            staffDTO.staff_id,
            staffDTO.staff_code,
            staffDTO.gender_id,
            staffDTO.village_id,
            staffDTO.manager_id,
            staffDTO.first_name,
            staffDTO.last_name,
            staffDTO.date_of_birth,
            staffDTO.position,
            staffDTO.department,
            staffDTO.employment_type,
            staffDTO.employment_start_date,
            staffDTO.employment_end_date,
            staffDTO.employment_level,
            staffDTO.current_address,
            staffDTO.home_address,
            staffDTO.street_address,
            staffDTO.photo_url,
            staffDTO.is_active,
            menuId,
            JSON.stringify(staffDTO.contact_data),
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.staffUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteStaff(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.staffDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async StaffExport(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.search_type, commonDTO.query_search, userId];
        console.log("Parameters for staff pagination:", parameters);
        try {
            const result = await this.call_tracker.query(SQL.staffExport, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}

