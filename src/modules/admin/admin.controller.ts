import { Body, Controller, ForbiddenException, Get, Param, Patch, Req, UseGuards } from '@nestjs/common';
import { AuthTokenGuard } from '../stores/auth-token.guard';
import { AdminGuard } from './admin.guard';
import { AdminService } from './admin.service';

type RequestWithUser = { user: { id: string; role: string } };

@Controller('admin')
@UseGuards(AuthTokenGuard, AdminGuard)
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Get('dashboard') dashboard() { return this.admin.dashboard(); }
  @Get('users') users() { return this.admin.users(); }
  @Get('stores') stores() { return this.admin.stores(); }
  @Get('listings') listings() { return this.admin.listings(); }
  @Get('orders') orders() { return this.admin.orders(); }
  @Get('finance') finance() { return this.admin.finance(); }
  @Get('classified-ad-plans') classifiedAdPlans() { return this.admin.classifiedAdPlans(); }

  @Patch('users/:id/status')
  setUserStatus(@Param('id') id: string, @Body() body: { status: string }, @Req() request: RequestWithUser) {
    if (id === request.user.id && body.status !== 'ACTIVE') {
      throw new ForbiddenException('Administrators cannot change their own account status');
    }
    return this.admin.setUserStatus(id, body.status);
  }

  @Patch('listings/:id/status')
  setListingStatus(@Param('id') id: string, @Body() body: { status: string }) {
    return this.admin.setListingStatus(id, body.status);
  }
}
