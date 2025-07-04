import { CommonService } from '../service/common.service';
export declare class CommonController {
    private readonly commonService;
    constructor(commonService: CommonService);
    getProvince(req: any): Promise<any>;
    getDistrictByProvinceID(id: number, req: any): Promise<any>;
    getCommuneByDistrictID(id: number, req: any): Promise<any>;
    getVillageByCommuneID(id: number, req: any): Promise<any>;
    getGender(req: any): Promise<any>;
    getBusiness(req: any): Promise<any>;
}
