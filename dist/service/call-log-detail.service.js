"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CallLogDetailService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let CallLogDetailService = class CallLogDetailService {
    call_tracker;
    constructor(call_tracker) {
        this.call_tracker = call_tracker;
    }
    async createCallLogDetail(callLogDetailDTO, userId, menuId) {
        const parameters = [
            callLogDetailDTO.call_log_id,
            callLogDetailDTO.contact_result_id,
            callLogDetailDTO.call_start_datetime,
            callLogDetailDTO.call_end_datetime,
            callLogDetailDTO.remark,
            menuId,
            JSON.stringify(callLogDetailDTO.contact_data),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.callLogDetailLogInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updateCallLogDetail(callLogDetailDTO, userId, menuId) {
        const parameters = [
            callLogDetailDTO.call_log_id,
            callLogDetailDTO.call_log_detail_id,
            callLogDetailDTO.contact_result_id,
            callLogDetailDTO.call_start_datetime,
            callLogDetailDTO.call_end_datetime,
            callLogDetailDTO.remark,
            callLogDetailDTO.is_active,
            menuId,
            JSON.stringify(callLogDetailDTO.contact_data),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.callLogDetailLogUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
};
exports.CallLogDetailService = CallLogDetailService;
exports.CallLogDetailService = CallLogDetailService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [typeorm_2.DataSource])
], CallLogDetailService);
//# sourceMappingURL=call-log-detail.service.js.map