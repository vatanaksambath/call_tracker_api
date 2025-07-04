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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PhotoUploadService = void 0;
const common_1 = require("@nestjs/common");
const cloudinary_1 = require("cloudinary");
let PhotoUploadService = class PhotoUploadService {
    constructor() {
        cloudinary_1.v2.config({
            cloud_name: 'dnavuqiv7',
            api_key: '745521149964891',
            api_secret: 'XssMAifZKAt4oiBKjUdZwTjMJcY',
        });
    }
    async uploadOneFileToCloud(file, entityId, menu) {
        const fs = require('fs/promises');
        try {
            const result = await cloudinary_1.v2.uploader.upload(file.path, {
                folder: `call_tracker/${menu}/${entityId}`,
            });
            const imageUrl = result.secure_url;
            if (file.path) {
                await fs.unlink(file.path);
            }
            return imageUrl;
        }
        catch (error) {
            console.error(`Cloudinary upload error for single file ${file.originalname}:`, error);
            throw new common_1.InternalServerErrorException(`Failed to upload single photo ${file.originalname} to cloud.`);
        }
    }
    async uploadMultipleFilesToCloud(files, entityId, menu) {
        const uploadedUrls = [];
        const fs = require('fs/promises');
        for (const file of files) {
            try {
                const result = await cloudinary_1.v2.uploader.upload(file.path, {
                    folder: `call_tracker/${menu}/${entityId}`,
                });
                const imageUrl = result.secure_url;
                uploadedUrls.push(imageUrl);
                if (file.path) {
                    await fs.unlink(file.path);
                }
            }
            catch (error) {
                console.error(`Cloudinary upload error for file ${file.originalname}:`, error);
                throw new common_1.InternalServerErrorException(`Failed to upload file ${file.originalname} to cloud.`);
            }
        }
        return uploadedUrls;
    }
};
exports.PhotoUploadService = PhotoUploadService;
exports.PhotoUploadService = PhotoUploadService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], PhotoUploadService);
//# sourceMappingURL=photo-upload.service.js.map