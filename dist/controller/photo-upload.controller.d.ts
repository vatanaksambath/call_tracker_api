import { PhotoUploadService } from '../service/photo-upload.service';
import { LeadService } from 'src/service/lead.service';
export declare class PhotoUploadController {
    private readonly photoUploadService;
    private readonly leadService;
    constructor(photoUploadService: PhotoUploadService, leadService: LeadService);
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
