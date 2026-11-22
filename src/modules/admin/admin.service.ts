import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async dashboard() {
    const [users, sellers, stores, listings, activeListings, orders, paidOrders, payments, paidPayments, pendingPayouts] = await Promise.all([
      this.prisma.user.count(), this.prisma.user.count({ where: { role: 'SELLER' } }),
      this.prisma.store.count(), this.prisma.listing.count(),
      this.prisma.listing.count({ where: { status: 'ACTIVE' } }),
      this.prisma.order.count(), this.prisma.order.count({ where: { status: 'PAID' } }),
      this.prisma.payment.count(), this.prisma.payment.count({ where: { status: 'PAID' } }),
      this.prisma.sellerPayout.count({ where: { status: { in: ['PENDING', 'PROCESSING'] } } }),
    ]);
    return { users, sellers, stores, listings, activeListings, orders, paidOrders, payments, paidPayments, pendingPayouts };
  }

  users() {
    return this.prisma.user.findMany({
      take: 100, orderBy: { createdAt: 'desc' },
      select: { id: true, email: true, phone: true, displayName: true, role: true, status: true, countryCode: true, createdAt: true },
    });
  }

  stores() {
    return this.prisma.store.findMany({
      take: 100, orderBy: { createdAt: 'desc' },
      include: { owner: { select: { id: true, email: true, phone: true, status: true } }, _count: { select: { listings: true } } },
    });
  }

  listings() {
    return this.prisma.listing.findMany({
      take: 100, orderBy: { createdAt: 'desc' },
      include: { store: { select: { id: true, name: true } }, seller: { select: { id: true, email: true, status: true } } },
    });
  }

  orders() {
    return this.prisma.order.findMany({
      take: 100, orderBy: { createdAt: 'desc' },
      include: {
        listing: { select: { id: true, title: true } },
        buyer: { select: { id: true, email: true } },
        seller: { select: { id: true, email: true } },
      },
    });
  }

  async setUserStatus(id: string, status: string) {
    if (!['ACTIVE', 'SUSPENDED', 'PENDING'].includes(status)) throw new BadRequestException('Invalid user status');
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return this.prisma.user.update({
      where: { id }, data: { status: status as 'ACTIVE' | 'SUSPENDED' | 'PENDING' },
      select: { id: true, email: true, phone: true, role: true, status: true },
    });
  }

  async setListingStatus(id: string, status: string) {
    if (!['DRAFT', 'ACTIVE', 'SOLD', 'ARCHIVED'].includes(status)) throw new BadRequestException('Invalid listing status');
    const listing = await this.prisma.listing.findUnique({ where: { id } });
    if (!listing) throw new NotFoundException('Listing not found');
    return this.prisma.listing.update({
      where: { id }, data: { status: status as 'DRAFT' | 'ACTIVE' | 'SOLD' | 'ARCHIVED' },
    });
  }
}
