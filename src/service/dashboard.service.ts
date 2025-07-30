import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';

@Injectable()
export class DashboardService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async DashboardSummary(userId: number) {
        try {
            const result = await this.call_tracker.query(SQL.dashboardSummary, [userId]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}

