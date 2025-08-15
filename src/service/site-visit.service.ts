import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { SiteVisitDTO } from 'src/dataModel/site-visit.dto';
import { CommonDTO} from 'src/dataModel/common.dto'

@Injectable()
export class SiteVisitService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async SiteVisitPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId]
        try {
            const result = await this.call_tracker.query(SQL.siteVisitPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createSiteVisit(siteVisitDTO: SiteVisitDTO, userId: number) {
        const parameters = [
            siteVisitDTO.call_id,
            siteVisitDTO.property_profile_id,
            siteVisitDTO.staff_id,
            siteVisitDTO.lead_id,
            siteVisitDTO.contact_result_id,
            siteVisitDTO.purpose,
            siteVisitDTO.start_datetime,
            siteVisitDTO.end_datetime,
            siteVisitDTO.photo_url,
            siteVisitDTO.remark,
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.siteVisitInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateSiteVisit(siteVisitDTO: SiteVisitDTO, userId: number) {
        const parameters = [
            siteVisitDTO.site_visit_id,
            siteVisitDTO.call_id,
            siteVisitDTO.property_profile_id,
            siteVisitDTO.staff_id,
            siteVisitDTO.lead_id,
            siteVisitDTO.contact_result_id,
            siteVisitDTO.purpose,
            siteVisitDTO.start_datetime,
            siteVisitDTO.end_datetime,
            siteVisitDTO.photo_url,
            siteVisitDTO.remark,
            siteVisitDTO.is_active,
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.siteVisitUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteSiteVisit(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.siteVisitDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async SiteVisitExport(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.call_log_id, userId]
        try {
            const result = await this.call_tracker.query(SQL.siteVisitExport, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}

