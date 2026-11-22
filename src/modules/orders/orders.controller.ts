import { Controller, Get, Post, Body, Req, UseGuards } from '@nestjs/common';
import { AuthTokenGuard } from '../stores/auth-token.guard';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';

type AuthenticatedRequest = { user: { id: string; role: string } };

@Controller('orders')
@UseGuards(AuthTokenGuard)
export class OrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Post()
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateOrderDto) {
    return this.orders.create(request.user.id, dto);
  }

  @Get('mine')
  mine(@Req() request: AuthenticatedRequest) {
    return this.orders.mine(request.user.id);
  }

  @Get('seller')
  sellerOrders(@Req() request: AuthenticatedRequest) {
    return this.orders.sellerOrders(request.user.id);
  }
}
