import { Module } from '@nestjs/common';
import { SupabaseProvider } from './supabase.provider';

@Module({
  providers: [SupabaseProvider],
  exports: [SupabaseProvider], // Export the provider so other modules can use it
})
export class SupabaseModule {}