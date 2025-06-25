import {
  Controller,
  Get,
  Post,
  Param,
  UploadedFile, // For single file upload
  UploadedFiles, // For multiple file uploads
  UseInterceptors,
  Body,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express'; // Import both interceptors
import { diskStorage } from 'multer';
import { extname } from 'path';
import { PhotoUploadService } from '../service/photo-upload.service';

@Controller('files')
export class PhotoUploadController {
  constructor(private readonly photoUploadService: PhotoUploadService) {}

  /**
   * Endpoint for uploading a single photo.
   * Uses FileInterceptor to handle one file.
   *
   * @param photo The single uploaded file.
   * @param entityId The ID of the entity to associate the photo with.
   * @returns An object containing the uploaded image URL and a success message.
   */
  @Post('upload-one-photo') // Endpoint for single photo upload
  @UseInterceptors(FileInterceptor('photo', { // 'photo' is the field name for a single file
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
        cb(null, `${randomName}${extname(file.originalname)}`);
      },
    }),
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit per file
    fileFilter: (req, file, cb) => {
      if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
        return cb(new Error('Only image files are allowed!'), false);
      }
      cb(null, true);
    },
  }))
  async uploadSinglePhoto(
    @UploadedFile() photo: Express.Multer.File,
    @Body('entityId') entityId: string,
  ) {
    if (!photo) {
      return { message: 'No file uploaded.' };
    }
    // Call the service method for single file upload
    const imageUrl = await this.photoUploadService.uploadOneFileToCloud(photo, entityId);
    return { imageUrl, message: 'Photo uploaded successfully!' };
  }

  /**
   * Endpoint for uploading multiple photos.
   * Uses FilesInterceptor to handle an array of files.
   *
   * @param files An array of uploaded files.
   * @param entityId The ID of the entity to associate the photos with.
   * @returns An object containing the uploaded image URLs and a success message.
   */
  @Post('upload-multiple-photos') // Endpoint for multiple photo uploads
  @UseInterceptors(FilesInterceptor('photos', 10, { // 'photos' is the field name, 10 is max count
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
        cb(null, `${randomName}${extname(file.originalname)}`);
      },
    }),
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit per file
    fileFilter: (req, file, cb) => {
      if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
        return cb(new Error('Only image files are allowed!'), false);
      }
      cb(null, true);
    },
  }))
  async uploadMultiplePhotos(
    @UploadedFiles() files: Array<Express.Multer.File>,
    @Body('entityId') entityId: string,
  ) {
    if (!files || files.length === 0) {
      return { message: 'No files uploaded.' };
    }
    // Call the service method for multiple file uploads
    const uploadedUrls = await this.photoUploadService.uploadMultipleFilesToCloud(files, entityId);
    return { imageUrls: uploadedUrls, message: 'Photos uploaded successfully!' };
  }

  /**
   * Endpoint to retrieve all photo URLs for a given entity.
   *
   * @param entityId The ID of the entity for which to retrieve photos.
   * @returns An object containing an array of photo URLs.
   * @throws NotFoundException if no photos are found for the entity.
   * @throws InternalServerErrorException if there's a server error during retrieval.
   */
  // @Get('photos/:entityId')
  // async getPhotoUrls(@Param('entityId') entityId: string): Promise<{ imageUrls: string[] }> {
  //   try {
  //     const imageUrls = await this.photoUploadService.getPhotoUrlsByEntityId(entityId);
  //     if (!imageUrls || imageUrls.length === 0) {
  //       throw new NotFoundException(`No photos found for entity ID: ${entityId}`);
  //     }
  //     return { imageUrls };
  //   } catch (error) {
  //     console.error('Error retrieving photo URLs:', error);
  //     throw new InternalServerErrorException('Failed to retrieve photo URLs.');
  //   }
  // }
}