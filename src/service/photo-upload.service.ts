// src/app.service.ts (Example)
import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { v2 as cloudinary } from 'cloudinary';// Assuming you use Prisma for DB interaction

@Injectable()
export class PhotoUploadService {
  constructor() {
    // Configure Cloudinary (add your credentials to .env)
    cloudinary.config({
      cloud_name: 'dnavuqiv7',
      api_key: '745521149964891',
      api_secret: 'XssMAifZKAt4oiBKjUdZwTjMJcY',
    });
  }

  async uploadFileToCloud(file: Express.Multer.File, entityId: string): Promise<string> {
    try {
      // Upload to Cloudinary
      const result = await cloudinary.uploader.upload(file.path || file.buffer.toString('base64'), {
        folder: `your-app-photos/${entityId}`, // Organize uploads by entity
        // Optional: Transformations here if needed
        // transformation: [{ width: 500, height: 500, crop: "limit" }]
      });

      const imageUrl = result.secure_url; // This is the public URL

    //   // Store the URL in your PostgreSQL database
    //   // Example: Assuming a 'leads' table with a 'photo_url' column
    //   await this.prisma.lead.update({
    //     where: { lead_id: entityId }, // Or relevant ID
    //     data: { photo_url: imageUrl },
    //   });

      // If using diskStorage, delete the temporary local file
      if (file.path) {
        // You might need to import 'fs/promises' for async unlink
        const fs = require('fs/promises');
        await fs.unlink(file.path);
      }

      return imageUrl;
    } catch (error) {
      console.error('Cloudinary upload error:', error);
      throw new InternalServerErrorException('Failed to upload photo to cloud.');
    }
  }
}