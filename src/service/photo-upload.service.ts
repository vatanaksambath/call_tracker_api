import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { v2 as cloudinary } from 'cloudinary';

@Injectable()
export class PhotoUploadService {
  constructor() {
      cloudinary.config({
      cloud_name: 'dnavuqiv7',
      api_key: '745521149964891',
      api_secret: 'XssMAifZKAt4oiBKjUdZwTjMJcY',
    });
  }

  /**
   * Uploads a single file to Cloudinary and stores its URL in the database.
   * Assumes a `tb_photos` table exists for storing photo URLs.
   *
   * @param file The Express.Multer.File object for the single photo.
   * @param entityId The ID of the entity (e.g., lead_id) to associate this photo with.
   * @returns A promise that resolves to the public URL for the uploaded photo.
   */
  async uploadOneFileToCloud(file: Express.Multer.File, entityId: string): Promise<string> {
    const fs = require('fs/promises');

    try {
      const result = await cloudinary.uploader.upload(file.path, {
        folder: `call_tracker/${entityId}`, // Organize uploads by entity
      });

      const imageUrl = result.secure_url;

      // Delete the temporary local file
      if (file.path) {
        await fs.unlink(file.path);
      }

      return imageUrl;
    } catch (error) {
      console.error(`Cloudinary upload error for single file ${file.originalname}:`, error);
      throw new InternalServerErrorException(`Failed to upload single photo ${file.originalname} to cloud.`);
    }
  }

  /**
   * Uploads multiple files to Cloudinary and stores their URLs in the database.
   * Assumes a `tb_photos` table exists for storing multiple photo URLs per entity.
   *
   * @param files An array of Express.Multer.File objects.
   * @param entityId The ID of the entity (e.g., lead_id) to associate these photos with.
   * @returns A promise that resolves to an array of public URLs for the uploaded photos.
   */
  async uploadMultipleFilesToCloud(files: Array<Express.Multer.File>, entityId: string): Promise<string[]> {
    const uploadedUrls: string[] = [];
    const fs = require('fs/promises');

    for (const file of files) {
      try {
        const result = await cloudinary.uploader.upload(file.path, {
          folder: `your-app-photos/${entityId}`,
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

  /**
   * Retrieves all photo URLs associated with a given entity ID from the database.
   * This function assumes your database structure has a `tb_photos` table
   * with `entity_id` and `photo_url` columns.
   *
   * @param entityId The ID of the entity (e.g., lead_id) for which to retrieve photos.
   * @returns A promise that resolves to an array of public photo URLs.
   */
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