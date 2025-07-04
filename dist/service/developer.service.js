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
exports.DeveloperService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let DeveloperService = class DeveloperService {
    call_tracker;
    constructor(call_tracker) {
        this.call_tracker = call_tracker;
    }
    async developerPagination(commonDTO, userId) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.developerPagination, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async createDeveloper(developerDTO, userId) {
        const parameters = [developerDTO.developer_name, developerDTO.developer_description, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.developerInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updateDeveloper(developerDTO, userId) {
        const parameters = [developerDTO.developer_id, developerDTO.developer_name, developerDTO.developer_description, developerDTO.is_active, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.developerUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async deleteDeveloper(id) {
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.developerDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
};
exports.DeveloperService = DeveloperService;
exports.DeveloperService = DeveloperService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [typeorm_2.DataSource])
], DeveloperService);
//# sourceMappingURL=developer.service.js.map