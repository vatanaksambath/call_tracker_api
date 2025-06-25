// src/app.controller.ts (Example)
import { Controller, Post, UploadedFile, UseInterceptors, Body } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer'; // Or memoryStorage if sending directly to cloud
import { extname } from 'path';
import { PhotoUploadService } from '../service/photo-upload.service';

@Controller('files')
export class PhotoUploadController {
  constructor(private readonly photoUploadService: PhotoUploadService) {}

  @Post('upload-photo')
  @UseInterceptors(FileInterceptor('photo', { // 'photo' is the field name from the form
    // Option 1: Store in memory (recommended for direct cloud upload)
    // storage: memoryStorage(),

    // Option 2: Store temporarily on disk (less common for direct cloud upload)
    storage: diskStorage({
      destination: './uploads', // Temporary local storage
      filename: (req, file, cb) => {
        const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
        cb(null, `${randomName}${extname(file.originalname)}`);
      },
    }),
    // You can add file size limits, file type filters etc.
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
      if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
        return cb(new Error('Only image files are allowed!'), false);
      }
      cb(null, true);
    },
  }))
  async uploadPhoto(
    @UploadedFile() photo: Express.Multer.File,
    @Body('entityId') entityId: string, // e.g., Lead ID, User ID
  ) {
    if (!photo) {
      // Handle no file uploaded
      return { message: 'No file uploaded.' };
    }
    // Now pass the file buffer (if using memoryStorage) or path (if diskStorage)
    // to your service for cloud upload
    const imageUrl = await this.photoUploadService.uploadFileToCloud(photo, entityId);
    return { imageUrl, message: 'Photo uploaded successfully!' };
  }
}