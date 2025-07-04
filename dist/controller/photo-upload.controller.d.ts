import { PhotoUploadService } from '../service/photo-upload.service';
export declare class PhotoUploadController {
    private readonly photoUploadService;
    constructor(photoUploadService: PhotoUploadService);
    uploadSinglePhoto(photo: Express.Multer.File, photoId: string, menu: string): Promise<{
        message: string;
        imageUrl?: undefined;
    } | {
        imageUrl: string;
        message: string;
    }>;
    uploadMultiplePhotos(files: Array<Express.Multer.File>, photoId: string, menu: string): Promise<{
        message: string;
        imageUrls?: undefined;
    } | {
        imageUrls: string[];
        message: string;
    }>;
}
