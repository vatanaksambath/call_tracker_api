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
exports.PropertyProfileService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let PropertyProfileService = class PropertyProfileService {
    call_tracker;
    constructor(call_tracker) {
        this.call_tracker = call_tracker;
    }
    async PropertyProfilePagination(commonDTO, userId) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.propertyProfilePagination, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async createPropertyProfile(propertyProfileDTO, userId) {
        const parameters = [
            propertyProfileDTO.property_type_id,
            propertyProfileDTO.project_id,
            propertyProfileDTO.project_owner_id,
            propertyProfileDTO.village_id,
            propertyProfileDTO.property_profile_name,
            propertyProfileDTO.home_number,
            propertyProfileDTO.room_number,
            propertyProfileDTO.address,
            propertyProfileDTO.width,
            propertyProfileDTO.length,
            propertyProfileDTO.remark,
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.propertyProfileInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updatePropertyProfile(propertyProfileDTO, userId) {
        const parameters = [
            propertyProfileDTO.property_profile_id,
            propertyProfileDTO.property_type_id,
            propertyProfileDTO.project_id,
            propertyProfileDTO.project_owner_id,
            propertyProfileDTO.village_id,
            propertyProfileDTO.property_profile_name,
            propertyProfileDTO.home_number,
            propertyProfileDTO.room_number,
            propertyProfileDTO.address,
            propertyProfileDTO.width,
            propertyProfileDTO.length,
            propertyProfileDTO.remark,
            propertyProfileDTO.is_active,
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.propertyProfileUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async deletePropertyProfile(id) {
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.propertyProfileDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
};
exports.PropertyProfileService = PropertyProfileService;
exports.PropertyProfileService = PropertyProfileService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [typeorm_2.DataSource])
], PropertyProfileService);
//# sourceMappingURL=property-profile.service.js.map