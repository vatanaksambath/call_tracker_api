import { DataSource } from 'typeorm';
export declare class CommonService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    getProvince(): Promise<any>;
    getDistrictByProvinceID(id: number): Promise<any>;
    getCommuneByDistrictID(id: number): Promise<any>;
    getVillageByCommuneID(id: number): Promise<any>;
    getGender(): Promise<any>;
    getBusiness(): Promise<any>;
}
