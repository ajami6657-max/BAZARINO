import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AiService {
  constructor(private readonly config: ConfigService) {}

  status() {
    const provider = this.config.get<string>('AI_PROVIDER', 'disabled');
    const configured = provider !== 'disabled' && Boolean(this.config.get<string>('AI_API_KEY'));
    return {
      module: 'bazarino-ai',
      status: configured ? 'configured' : 'disabled',
      provider,
      capabilities: ['listing_enrichment', 'translation', 'support_drafts', 'moderation_triage'],
      safeguards: ['human_review_for_enforcement', 'no_automated_payouts', 'no_unverified_claims'],
    };
  }
}
