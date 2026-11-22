import { ConflictException, Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  private safeUser(user: { id: string; email: string | null; phone: string | null; displayName: string | null; role: string; countryCode: string; locale: string }) {
    return {
      id: user.id,
      email: user.email,
      phone: user.phone,
      displayName: user.displayName,
      role: user.role,
      countryCode: user.countryCode,
      locale: user.locale,
    };
  }

  private async issueToken(user: { id: string; role: string }) {
    const secret = this.config.get<string>('JWT_SECRET');
    if (!secret || secret.length < 32) {
      throw new Error('JWT_SECRET must be configured with at least 32 characters');
    }
    return this.jwt.signAsync({ sub: user.id, role: user.role });
  }

  async verifyAccessToken(token: string): Promise<{ sub: string; role: string }> {
    try {
      const payload = await this.jwt.verifyAsync<{ sub: string; role: string }>(token);
      if (!payload.sub) throw new UnauthorizedException('Invalid access token');
      return payload;
    } catch {
      throw new UnauthorizedException('Invalid or expired access token');
    }
  }

  async register(dto: RegisterDto) {
    const email = dto.email?.trim().toLowerCase();
    const phone = dto.phone?.trim();
    if (!email && !phone) {
      throw new BadRequestException('Provide an email address or phone number');
    }
    try {
      const passwordHash = await bcrypt.hash(dto.password, 12);
      const user = await this.prisma.user.create({
        data: {
          email,
          phone,
          passwordHash,
          displayName: dto.displayName?.trim(),
        },
      });
      const accessToken = await this.issueToken(user);
      return { accessToken, tokenType: 'Bearer', user: this.safeUser(user) };
    } catch (error) {
      if (typeof error === 'object' && error !== null && 'code' in error && error.code === 'P2002') {
        throw new ConflictException('An account with this email or phone already exists');
      }
      throw error;
    }
  }

  async login(dto: LoginDto) {
    const identifier = dto.identifier.trim();
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: identifier.toLowerCase() },
          { phone: identifier },
        ],
      },
    });
    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Invalid credentials');
    }
    if (user.status !== 'ACTIVE') {
      throw new UnauthorizedException('This account is not active');
    }
    const accessToken = await this.issueToken(user);
    return { accessToken, tokenType: 'Bearer', user: this.safeUser(user) };
  }
}
