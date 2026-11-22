import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AuthTokenGuard } from './auth-token.guard';
import { StoresController } from './stores.controller';
import { StoresService } from './stores.service';

@Module({
  imports: [AuthModule],
  controllers: [StoresController],
  providers: [StoresService, AuthTokenGuard],
})
export class StoresModule {}
