import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AuthTokenGuard } from '../stores/auth-token.guard';
import { ClassifiedsController } from './classifieds.controller';
import { ClassifiedsService } from './classifieds.service';

@Module({
  imports: [AuthModule],
  controllers: [ClassifiedsController],
  providers: [ClassifiedsService, AuthTokenGuard],
})
export class ClassifiedsModule {}
