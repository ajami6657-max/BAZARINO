import { Body, Controller, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { AuthTokenGuard } from '../stores/auth-token.guard';
import { CreateClassifiedAdDto } from './dto/create-classified-ad.dto';
import { ClassifiedsService } from './classifieds.service';

type AuthenticatedRequest = { user: { id: string; role: string } };

@Controller('classifieds')
export class ClassifiedsController {
  constructor(private readonly classifieds: ClassifiedsService) {}

  @Get('plans')
  plans() { return this.classifieds.plans(); }

  @Get()
  search(
    @Query('q') q?: string,
    @Query('city') city?: string,
    @Query('category') category?: string,
    @Query('adType') adType?: string,
    @Query('countryCode') countryCode?: string,
  ) {
    return this.classifieds.search(q, city, category, adType, countryCode);
  }

  @Post()
  @UseGuards(AuthTokenGuard)
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateClassifiedAdDto) {
    return this.classifieds.create(request.user.id, dto);
  }

  @Get('mine')
  @UseGuards(AuthTokenGuard)
  mine(@Req() request: AuthenticatedRequest) {
    return this.classifieds.mine(request.user.id);
  }

  @Patch(':id/sold')
  @UseGuards(AuthTokenGuard)
  sold(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    return this.classifieds.setStatus(request.user.id, id, 'SOLD');
  }

  @Patch(':id/archive')
  @UseGuards(AuthTokenGuard)
  archive(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    return this.classifieds.setStatus(request.user.id, id, 'ARCHIVED');
  }
}
