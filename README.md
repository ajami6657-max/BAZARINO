# BAZARINO 🌍
**AI-assisted global marketplace — built mobile-first.**

Bazarino is a multi-country marketplace foundation combining listings, storefronts, social discovery, messaging and AI-assisted operations. This repository is the first runnable foundation, not a claim that payments, shipping or autonomous AI operations are already live.

## Architecture
- API: NestJS + TypeScript
- Database: PostgreSQL + Prisma
- Mobile: Flutter / Dart (Android + iOS, single codebase)
- API prefix: `/api/v1`
- International-ready fields: ISO country codes, BCP-47 locale codes, ISO currency codes, localized product content.

## Mobile app
The mobile client uses Flutter; Expo and React Native have been removed. See `mobile/README.md` for local run instructions. GitHub Actions runs Flutter static analysis.

## Start the API
```bash
cp .env.example .env
npm install
npx prisma generate
npm run start:dev
```
Set `DATABASE_URL` to a PostgreSQL database before running migrations:
```bash
npx prisma migrate deploy
```

## API
- `GET /api/v1/health` — liveness check
- `GET /api/v1/ai/status` — AI module readiness and configured provider status
- `POST /api/v1/auth/register` — register with email or phone
- `POST /api/v1/auth/login` — sign in with email or phone
- `POST /api/v1/stores` — create a free seller store (Bearer token required); defaults to IRR for Iran and USD elsewhere
- `GET /api/v1/stores/me` — retrieve the signed-in seller's store
- `POST /api/v1/listings` — create a product draft for the signed-in seller's store (Bearer token required)
- `GET /api/v1/listings/mine` — list the signed-in seller's products (Bearer token required)
- `GET /api/v1/listings` — search active products; optional `q`, `category`, and `countryCode` query parameters
- `PATCH /api/v1/listings/:id/archive` — archive one of the seller's own products (Bearer token required)

New products start as drafts and are not publicly searchable until a later publishing/moderation flow activates them.

## Payments and seller commission
- Platform commission is configured as **0.5% (50 basis points)** by default.
- Each payment stores an immutable checkout-time snapshot: gross amount, commission rate, platform fee, seller net amount and currency.
- Seller payout accounts store only the payment provider's beneficiary token/reference and masked account suffix; never store card numbers, CVV or raw banking credentials.
- Payouts are tracked separately from successful customer payments. A payment is not marked as paid out until the provider confirms the transfer.
- The provider integration must support split settlement or an approved payout/transfer API for the seller's country and currency. Until a provider is configured and legally enabled, checkout and automatic payouts remain disabled.
- Payment webhooks must be signature-verified and idempotent before they can mark a payment paid or initiate a payout. Refunds, disputes and payout failures require audited handling.
- Do not assume one gateway can serve every country. Enable providers only after merchant onboarding, country eligibility and settlement support are verified.

## AI operating principle
AI is an assistant for moderation triage, listing enrichment, translation and support drafts. Financial actions, payouts, account bans and dispute outcomes must require explicit policy checks and/or human review. No fake autonomous actions or guaranteed earnings.

## Security
Never commit secrets. Configure production secrets in the deployment platform. Do not store card data. Configure a strong random `JWT_SECRET` of at least 32 characters. Use a licensed payment provider for each supported country and verify legal availability before enabling checkout.
