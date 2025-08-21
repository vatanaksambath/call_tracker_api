import { Injectable, Logger } from '@nestjs/common';
import * as csv from 'csv-parser';
import { Readable } from 'stream';
import { dispatchBadRequestException } from '../common/error-handler.util';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from 'src/common/query.common';

@Injectable()
export class LeadImportService {
    private readonly logger = new Logger(LeadImportService.name);

    constructor(@InjectDataSource() private call_tracker: DataSource) {}

    private parseCsv(fileBuffer: Buffer): Promise<any[]> {
        return new Promise((resolve, reject) => {
            const results: any[] = [];
            const stream = Readable.from(fileBuffer);
            stream
                .pipe(csv())
                .on('data', (data) => results.push(data))
                .on('end', () => resolve(results))
                .on('error', (error) => reject(error));
        });
    }

    async importLeads(file: Express.Multer.File, userId: number) {
        this.logger.log(`Initiating CSV import for user ID: ${userId}`);
        if (!file) {
            this.logger.warn('Import attempt failed: No file was uploaded.');
            dispatchBadRequestException('No file uploaded.');
        }

        const STATIC_PROPERTY_PROFILE_ID = 14;
        const STATIC_STATUS_ID = 1;

        try {
            const incompleteLeadsData = await this.parseCsv(file.buffer);
            if (incompleteLeadsData.length === 0) {
                this.logger.warn(`CSV file uploaded by user ${userId} is empty.`);
                return {
                    status: 'warning',
                    message: 'CSV file is empty or could not be parsed.',
                    records_processed: 0,
                };
            }
            
            const leadsData = incompleteLeadsData.map(lead => ({
                first_name: lead.first_name ?? null,
                last_name: lead.last_name ?? null,
                phone_number: lead.phone_number ?? null,
                staff_id: lead.staff_id ?? null,
                gender_id: 999999,
                customer_type_id: 4,
                lead_source_id: 5,
                village_id: 999999,
                business_id: 1,
                date_of_birth: null,
                occupation: null,
                email: null,
                home_address: null,
                street_address: null,
                biz_description: null,
                relationship_date: null,
                remark: null,
                photo_url: null,
            }));

            const leadsJsonString = JSON.stringify(leadsData);
                     
            const parameters = [leadsJsonString, STATIC_PROPERTY_PROFILE_ID, STATIC_STATUS_ID, userId];
            const response = await this.call_tracker.query(SQL.importLeadsAndCreateCallLogs, parameters);

            if (!response || response.length === 0) {
                this.logger.error('Database function did not return a result.');
                dispatchBadRequestException('Failed to get a response from the database.');
            }

            const result = response[0].import_leads_and_create_call_logs;

            if (result.status === 'error') {
                this.logger.error(`Database function failed during import: ${result.message}`);
                dispatchBadRequestException(result.message);
            }
            
            this.logger.log(`Successfully processed ${result.records_processed} records for user ${userId}.`);
            
            return result;
        } catch (error) {
            this.logger.error(`An unhandled error occurred during the import process for user ${userId}.`, error.stack);
            dispatchBadRequestException(error);
        }
    }
}