import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { ChannelTypeDTO } from '../dataModel/channel-type.dto';
import { CommonDTO} from 'src/dataModel/common.dto';

@Injectable()
export class ChannelTypeService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async ChannelTypePagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search]
        try {
            const result = await this.call_tracker.query(SQL.channelTypePagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async ChannelTypeSummary(userId: number) {
        try {
             if (!userId) {
                throw new Error('User ID is required');
            }
            const result = await this.call_tracker.query(SQL.channelTypeSummary, [userId]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createChannelType(channelTypeDTO: ChannelTypeDTO, userId: number) {
        const parameters = [channelTypeDTO.channel_type_name, channelTypeDTO.channel_type_description, userId]
        try {
            const result = await this.call_tracker.query(SQL.channelTypeInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateChannelType(channelTypeDTO: ChannelTypeDTO, userId: number) {
        const parameters = [channelTypeDTO.channel_type_id, channelTypeDTO.channel_type_name, channelTypeDTO.channel_type_description, channelTypeDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.channelTypeUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteChannelType(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.channelTypeDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async getChannelType() {
        try {
            const result = await this.call_tracker.query( SQL.getChannelType);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}

