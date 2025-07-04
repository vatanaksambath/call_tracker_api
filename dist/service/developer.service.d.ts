import { DataSource } from 'typeorm';
import { DeveloperDTO } from 'src/dataModel/developer.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class DeveloperService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    developerPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createDeveloper(developerDTO: DeveloperDTO, userId: number): Promise<any>;
    updateDeveloper(developerDTO: DeveloperDTO, userId: number): Promise<any>;
    deleteDeveloper(id: number | string): Promise<any>;
}
