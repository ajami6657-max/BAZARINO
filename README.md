# BAZARINO 🌍
**AI-assisted global marketplace — built mobile-first.**

Bazarino is a multi-country marketplace foundation combining listings, storefronts, social discovery, messaging and AI-assisted operations. This repository is the first runnable foundation, not a claim that payments, shipping or autonomous AI operations are already live.

## Architecture
- API: NestJS + TypeScript
- Database: PostgreSQL + Prisma
- Mobile: Expo / React Native
- API prefix: `/api/v1`
- International-ready fields: ISO country codes, BCP-47 locale codes, ISO currency codes, localized product content.

## Start the API
```bash
cp .env.example .env
npm install
npx prisma generate
npm run start:dev
```
Set `DATABASE_URL` to a PostgreSQL database before running migrations:
```bash
npx prisma migrate dev --name init
```

## API
- `GET /api/v1/health` — liveness check
- `GET /api/v1/ai/status` — AI module readiness and configured provider status

## AI operating principle
AI is an assistant for moderation triage, listing enrichment, translation and support drafts. Financial actions, payouts, account bans and dispute outcomes must require explicit policy checks and/or human review. No fake autonomous actions or guaranteed earnings.

## Current scope
This commit establishes the API, database schema, health endpoint, AI service boundary, environment template and mobile starter. Authentication, marketplace workflows, moderation queues, payments, shipping integrations and production AI providers are next milestones.

## Security
Never commit secrets. Configure production secrets in the deployment platform. Do not store card data. Use a licensed payment provider for each supported country and verify legal availability before enabling checkout.
