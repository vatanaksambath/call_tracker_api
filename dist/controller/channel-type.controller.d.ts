import { ChannelTypeService } from '../service/channel-type.service';
import { ChannelTypeDTO } from 'src/dataModel/channel-type.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class ChannelTypeController {
    private readonly channelTypeService;
    constructor(channelTypeService: ChannelTypeService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(ChannelTypeDTO: ChannelTypeDTO, req: any): Promise<any>;
    update(ChannelTypeDTO: ChannelTypeDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
    getCustomerType(req: any): Promise<any>;
}
