import {Controller,Get,Post,Param,UploadedFile,UploadedFiles,UseInterceptors,Body,InternalServerErrorException,NotFoundException} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { PhotoUploadService } from '../service/photo-upload.service';

@Controller('files')
export class PhotoUploadController {
  constructor(private readonly photoUploadService: PhotoUploadService) {}
  
  @Post('upload-one-photo') 
  @UseInterceptors(FileInterceptor('photo', { 
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
    @Body('photoId') photoId: string,
    @Body('menu') menu: string,
  ) {
    if (!photo) {
      return { message: 'No file uploaded.' };
    }
    const imageUrl = await this.photoUploadService.uploadOneFileToCloud(photo, photoId, menu);
    return { imageUrl, message: 'Photo uploaded successfully!' };
  }

  @Post('upload-multiple-photos') 
  @UseInterceptors(FilesInterceptor('photo', 10, {
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
    @Body('photoId') photoId: string,
    @Body('menu') menu: string,
  ) {
    if (!files || files.length === 0) {
      return { message: 'No files uploaded.' };
    }
    const uploadedUrls = await this.photoUploadService.uploadMultipleFilesToCloud(files, photoId, menu);
    return { imageUrls: uploadedUrls, message: 'Photos uploaded successfully!' };
  }

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