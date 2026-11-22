import { Controller, Get, Module } from '@nestjs/common';
import { AiService } from './ai.service';

@Controller('ai')
class AiController {
  constructor(private readonly ai: AiService) {}
  @Get('status') status() { return this.ai.status(); }
}

@Module({ controllers: [AiController], providers: [AiService], exports: [AiService] })
export class AiModule {}
