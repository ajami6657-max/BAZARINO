import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AuthTokenGuard } from '../stores/auth-token.guard';
import { ListingsController } from './listings.controller';
import { ListingsService } from './listings.service';

@Module({
  imports: [AuthModule],
  controllers: [ListingsController],
  providers: [ListingsService, AuthTokenGuard],
})
export class ListingsModule {}
