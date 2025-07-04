import { DataSource } from 'typeorm';
import { SiteVisitDTO } from 'src/dataModel/site-visit.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class SiteVisitService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    SiteVisitPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createSiteVisit(siteVisitDTO: SiteVisitDTO, userId: number): Promise<any>;
    updateSiteVisit(siteVisitDTO: SiteVisitDTO, userId: number): Promise<any>;
    deleteSiteVisit(id: number | string): Promise<any>;
}
