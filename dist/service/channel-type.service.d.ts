import { DataSource } from 'typeorm';
import { ChannelTypeDTO } from '../dataModel/channel-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class ChannelTypeService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    ChannelTypePagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createChannelType(channelTypeDTO: ChannelTypeDTO, userId: number): Promise<any>;
    updateChannelType(channelTypeDTO: ChannelTypeDTO, userId: number): Promise<any>;
    deleteChannelType(id: number | string): Promise<any>;
    getChannelType(): Promise<any>;
}
