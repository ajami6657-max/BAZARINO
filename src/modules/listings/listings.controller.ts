import { Body, Controller, Get, Post, Query, Req, UseGuards, Param, Patch } from '@nestjs/common';
import { AuthTokenGuard } from '../stores/auth-token.guard';
import { CreateListingDto } from './dto/create-listing.dto';
import { ListingsService } from './listings.service';

type AuthenticatedRequest = { user: { id: string; role: string } };

@Controller('listings')
export class ListingsController {
  constructor(private readonly listings: ListingsService) {}

  @Get()
  search(
    @Query('q') query?: string,
    @Query('category') category?: string,
    @Query('countryCode') countryCode?: string,
  ) {
    return this.listings.publicSearch(query, category, countryCode);
  }

  @Post()
  @UseGuards(AuthTokenGuard)
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateListingDto) {
    return this.listings.create(request.user.id, dto);
  }

  @Get('mine')
  @UseGuards(AuthTokenGuard)
  mine(@Req() request: AuthenticatedRequest) {
    return this.listings.mine(request.user.id);
  }

  @Patch(':id/archive')
  @UseGuards(AuthTokenGuard)
  archive(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    return this.listings.archive(request.user.id, id);
  }
}
