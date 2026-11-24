ALTER TABLE "ClassifiedAd"
  ADD COLUMN "planCode" TEXT NOT NULL DEFAULT 'P1',
  ADD COLUMN "planDurationDays" INTEGER NOT NULL DEFAULT 30,
  ADD COLUMN "planPriceToman" INTEGER NOT NULL DEFAULT 50000,
  ADD COLUMN "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN "expiresAt" TIMESTAMP(3);
UPDATE "ClassifiedAd" SET "expiresAt" = "createdAt" + INTERVAL '30 days';
ALTER TABLE "ClassifiedAd" ALTER COLUMN "expiresAt" SET NOT NULL;
CREATE INDEX "ClassifiedAd_status_expiresAt_idx" ON "ClassifiedAd"("status", "expiresAt");
