export declare class PhotoUploadService {
    constructor();
    uploadOneFileToCloud(file: Express.Multer.File, entityId: string, menu: string): Promise<string>;
    uploadMultipleFilesToCloud(files: Array<Express.Multer.File>, entityId: string, menu: string): Promise<string[]>;
}
