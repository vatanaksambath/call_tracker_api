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
exports.LeadService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let LeadService = class LeadService {
    call_tracker;
    constructor(call_tracker) {
        this.call_tracker = call_tracker;
    }
    async LeadPagination(commonDTO, userId) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.leadPagination, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async createLead(leadDTO, userId, menuId) {
        const parameters = [
            leadDTO.gender_id,
            leadDTO.customer_type_id,
            leadDTO.lead_source_id,
            leadDTO.village_id,
            leadDTO.business_id,
            leadDTO.initial_staff_id,
            leadDTO.current_staff_id,
            leadDTO.first_name,
            leadDTO.last_name,
            leadDTO.date_of_birth,
            leadDTO.email,
            leadDTO.occupation,
            leadDTO.home_address,
            leadDTO.street_address,
            leadDTO.biz_description,
            leadDTO.relationship_date,
            leadDTO.remark,
            leadDTO.photo_url,
            menuId,
            JSON.stringify(leadDTO.contact_data),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.leadInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updateLead(leadDTO, userId, menuId) {
        const parameters = [
            leadDTO.lead_id,
            leadDTO.gender_id,
            leadDTO.customer_type_id,
            leadDTO.lead_source_id,
            leadDTO.village_id,
            leadDTO.business_id,
            leadDTO.initial_staff_id,
            leadDTO.current_staff_id,
            leadDTO.first_name,
            leadDTO.last_name,
            leadDTO.date_of_birth,
            leadDTO.email,
            leadDTO.occupation,
            leadDTO.home_address,
            leadDTO.street_address,
            leadDTO.biz_description,
            leadDTO.relationship_date,
            leadDTO.remark,
            leadDTO.photo_url,
            leadDTO.is_active,
            menuId,
            JSON.stringify(leadDTO.contact_data),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.leadUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async deleteLead(id) {
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.leadDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
};
exports.LeadService = LeadService;
exports.LeadService = LeadService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [typeorm_2.DataSource])
], LeadService);
//# sourceMappingURL=lead.service.js.map