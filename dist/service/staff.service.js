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
exports.StaffService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let StaffService = class StaffService {
    call_tracker;
    constructor(call_tracker) {
        this.call_tracker = call_tracker;
    }
    async StaffPagination(commonDTO, userId) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId];
        console.log("Parameters for staff pagination:", parameters);
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.staffPagination, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async createStaff(staffDTO, userId, menuId) {
        const parameters = [
            staffDTO.staff_id,
            staffDTO.staff_code,
            staffDTO.gender_id,
            staffDTO.village_id,
            staffDTO.manager_id,
            staffDTO.first_name,
            staffDTO.last_name,
            staffDTO.date_of_birth,
            staffDTO.position,
            staffDTO.department,
            staffDTO.employment_type,
            staffDTO.employment_start_date,
            staffDTO.employment_end_date,
            staffDTO.employment_level,
            staffDTO.current_address,
            staffDTO.photo_url,
            menuId,
            JSON.stringify(staffDTO.contact_data),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.staffInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updateStaff(staffDTO, userId, menuId) {
        const parameters = [
            staffDTO.staff_id,
            staffDTO.staff_code,
            staffDTO.gender_id,
            staffDTO.village_id,
            staffDTO.manager_id,
            staffDTO.first_name,
            staffDTO.last_name,
            staffDTO.date_of_birth,
            staffDTO.position,
            staffDTO.department,
            staffDTO.employment_type,
            staffDTO.employment_start_date,
            staffDTO.employment_end_date,
            staffDTO.employment_level,
            staffDTO.current_address,
            staffDTO.photo_url,
            staffDTO.is_active,
            menuId,
            JSON.stringify(staffDTO.contact_data),
            userId
        ];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.staffUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async deleteStaff(id) {
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.staffDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
};
exports.StaffService = StaffService;
exports.StaffService = StaffService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [typeorm_2.DataSource])
], StaffService);
//# sourceMappingURL=staff.service.js.map