import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { AuthTokenGuard } from './auth-token.guard';
import { CreateStoreDto } from './dto/create-store.dto';
import { StoresService } from './stores.service';

type AuthenticatedRequest = { user: { id: string; role: string } };

@Controller('stores')
@UseGuards(AuthTokenGuard)
export class StoresController {
  constructor(private readonly stores: StoresService) {}

  @Post()
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateStoreDto) {
    return this.stores.create(request.user.id, dto);
  }

  @Get('me')
  mine(@Req() request: AuthenticatedRequest) {
    return this.stores.mine(request.user.id);
  }
}
