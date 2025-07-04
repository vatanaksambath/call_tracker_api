import { SiteVisitService } from '../service/site-visit.service';
import { SiteVisitDTO } from 'src/dataModel/site-visit.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class SiteVisitController {
    private readonly siteVisitService;
    constructor(siteVisitService: SiteVisitService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(SiteVisitDTO: SiteVisitDTO, req: any): Promise<any>;
    update(SiteVisitDTO: SiteVisitDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
