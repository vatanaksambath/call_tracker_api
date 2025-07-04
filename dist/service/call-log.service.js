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
exports.CallLogService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let CallLogService = class CallLogService {
    call_tracker;
    constructor(call_tracker) {
        this.call_tracker = call_tracker;
    }
    async CallLogPagination(commonDTO, userId) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.callLogPagination, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async createCallLog(callLogDTO, userId, menuId) {
        const parameters = [
            callLogDTO.lead_id,
            callLogDTO.property_profile_id,
            callLogDTO.status_id,
            callLogDTO.purpose,
            callLogDTO.fail_reason,
            JSON.stringify(callLogDTO.p_call_log_detail),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.callLogInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updateCallLog(callLogDTO, userId, menuId) {
        const parameters = [
            callLogDTO.call_log_id,
            callLogDTO.lead_id,
            callLogDTO.property_profile_id,
            callLogDTO.status_id,
            callLogDTO.purpose,
            callLogDTO.fail_reason,
            callLogDTO.is_active,
            JSON.stringify(callLogDTO.p_call_log_detail),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.callLogUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async deleteCallLog(id) {
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.callLogDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
};
exports.CallLogService = CallLogService;
exports.CallLogService = CallLogService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [typeorm_2.DataSource])
], CallLogService);
//# sourceMappingURL=call-log.service.js.map