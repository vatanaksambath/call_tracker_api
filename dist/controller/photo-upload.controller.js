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
exports.PhotoUploadController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const multer_1 = require("multer");
const path_1 = require("path");
const photo_upload_service_1 = require("../service/photo-upload.service");
let PhotoUploadController = class PhotoUploadController {
    photoUploadService;
    constructor(photoUploadService) {
        this.photoUploadService = photoUploadService;
    }
    async uploadSinglePhoto(photo, photoId, menu) {
        if (!photo) {
            return { message: 'No file uploaded.' };
        }
        const imageUrl = await this.photoUploadService.uploadOneFileToCloud(photo, photoId, menu);
        return { imageUrl, message: 'Photo uploaded successfully!' };
    }
    async uploadMultiplePhotos(files, photoId, menu) {
        if (!files || files.length === 0) {
            return { message: 'No files uploaded.' };
        }
        const uploadedUrls = await this.photoUploadService.uploadMultipleFilesToCloud(files, photoId, menu);
        return { imageUrls: uploadedUrls, message: 'Photos uploaded successfully!' };
    }
};
exports.PhotoUploadController = PhotoUploadController;
__decorate([
    (0, common_1.Post)('upload-one-photo'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('photo', {
        storage: (0, multer_1.diskStorage)({
            destination: './uploads',
            filename: (req, file, cb) => {
                const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
                cb(null, `${randomName}${(0, path_1.extname)(file.originalname)}`);
            },
        }),
        limits: { fileSize: 5 * 1024 * 1024 },
        fileFilter: (req, file, cb) => {
            if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
                return cb(new Error('Only image files are allowed!'), false);
            }
            cb(null, true);
        },
    })),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Body)('photoId')),
    __param(2, (0, common_1.Body)('menu')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], PhotoUploadController.prototype, "uploadSinglePhoto", null);
__decorate([
    (0, common_1.Post)('upload-multiple-photos'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FilesInterceptor)('photo', 10, {
        storage: (0, multer_1.diskStorage)({
            destination: './uploads',
            filename: (req, file, cb) => {
                const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
                cb(null, `${randomName}${(0, path_1.extname)(file.originalname)}`);
            },
        }),
        limits: { fileSize: 5 * 1024 * 1024 },
        fileFilter: (req, file, cb) => {
            if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
                return cb(new Error('Only image files are allowed!'), false);
            }
            cb(null, true);
        },
    })),
    __param(0, (0, common_1.UploadedFiles)()),
    __param(1, (0, common_1.Body)('photoId')),
    __param(2, (0, common_1.Body)('menu')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Array, String, String]),
    __metadata("design:returntype", Promise)
], PhotoUploadController.prototype, "uploadMultiplePhotos", null);
exports.PhotoUploadController = PhotoUploadController = __decorate([
    (0, common_1.Controller)('files'),
    __metadata("design:paramtypes", [photo_upload_service_1.PhotoUploadService])
], PhotoUploadController);
//# sourceMappingURL=photo-upload.controller.js.map