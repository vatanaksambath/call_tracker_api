import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';

@Injectable()
export class PhotoUploadService {
  constructor(private configService: ConfigService) {
      cloudinary.config({
      cloud_name: this.configService.get('CLOUDINARY_CLOUD_NAME'),
      api_key: this.configService.get('CLOUDINARY_API_KEY'),
      api_secret: this.configService.get('CLOUDINARY_API_SECRET'),
    });
  }

  async uploadOneFileToCloud(file: Express.Multer.File, entityId: string, menu: string): Promise<string> {
    const fs = require('fs/promises');

    try {
      const result = await cloudinary.uploader.upload(file.path, {
        folder: `call_tracker/${menu}/${entityId}`,
      });

      const imageUrl = result.secure_url;

      if (file.path) {
        await fs.unlink(file.path);
      }

      return imageUrl;
    } catch (error) {
      console.error(`Cloudinary upload error for single file ${file.originalname}:`, error);
      throw new InternalServerErrorException(`Failed to upload single photo ${file.originalname} to cloud.`);
    }
  }

  async uploadMultipleFilesToCloud(files: Array<Express.Multer.File>, entityId: string, menu: string): Promise<string[]> {
    const uploadedUrls: string[] = [];
    const fs = require('fs/promises');

    for (const file of files) {
      try {
        const result = await cloudinary.uploader.upload(file.path, {
          folder: `call_tracker/${menu}/${entityId}`,
        });

        const imageUrl = result.secure_url;
        uploadedUrls.push(imageUrl);

        if (file.path) {
          await fs.unlink(file.path);
        }
      } catch (error) {
        console.error(`Cloudinary upload error for file ${file.originalname}:`, error);
        throw new InternalServerErrorException(`Failed to upload file ${file.originalname} to cloud.`);
      }
    }
    return uploadedUrls;
  }

  // async getPhotoUrlsByEntityId(entityId: string): Promise<string[]> {
  //   try {
  //     const photos = await this.prisma.tb_photos.findMany({
  //       where: { entity_id: entityId },
  //       select: { photo_url: true },
  //     });

  //     if (!photos || photos.length === 0) {
  //       return [];
  //     }

  //     return photos.map(photo => photo.photo_url);
  //   } catch (error) {
  //     console.error(`Database retrieval error for photos for entity ${entityId}:`, error);
  //     throw error;
  //   }
  // }
}