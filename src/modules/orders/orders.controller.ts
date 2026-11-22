import { Body, Controller, Delete, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { AuthTokenGuard } from '../stores/auth-token.guard';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';

type AuthenticatedRequest = { user: { id: string; role: string } };

@Controller()
@UseGuards(AuthTokenGuard)
export class OrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Get('cart')
  cart(@Req() request: AuthenticatedRequest) { return this.orders.cart(request.user.id); }

  @Post('cart/items')
  addToCart(@Req() request: AuthenticatedRequest, @Body() dto: AddCartItemDto) { return this.orders.addToCart(request.user.id, dto); }

  @Delete('cart/items/:listingId')
  removeFromCart(@Req() request: AuthenticatedRequest, @Param('listingId') listingId: string) { return this.orders.removeFromCart(request.user.id, listingId); }

  @Post('cart/checkout')
  checkoutCart(@Req() request: AuthenticatedRequest) { return this.orders.checkoutCart(request.user.id); }

  @Post('orders')
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateOrderDto) { return this.orders.create(request.user.id, dto); }

  @Get('orders/mine')
  mine(@Req() request: AuthenticatedRequest) { return this.orders.mine(request.user.id); }

  @Get('orders/seller')
  sellerOrders(@Req() request: AuthenticatedRequest) { return this.orders.sellerOrders(request.user.id); }

  @Post('orders/:id/cancel')
  cancel(@Req() request: AuthenticatedRequest, @Param('id') id: string) { return this.orders.cancel(request.user.id, id); }

  @Post('orders/:id/fulfill')
  fulfill(@Req() request: AuthenticatedRequest, @Param('id') id: string) { return this.orders.fulfill(request.user.id, id); }
}
