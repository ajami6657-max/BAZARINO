CREATE TYPE "ClassifiedAdType" AS ENUM ('GOODS', 'VEHICLE', 'REAL_ESTATE', 'SERVICES', 'JOBS');
CREATE TYPE "ClassifiedAdStatus" AS ENUM ('ACTIVE', 'SOLD', 'ARCHIVED');
CREATE TABLE "ClassifiedAd" (
  "id" TEXT NOT NULL,
  "ownerId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "category" TEXT NOT NULL,
  "adType" "ClassifiedAdType" NOT NULL DEFAULT 'GOODS',
  "condition" TEXT,
  "price" DECIMAL(18,4),
  "currency" TEXT NOT NULL DEFAULT 'IRR',
  "isNegotiable" BOOLEAN NOT NULL DEFAULT false,
  "isFree" BOOLEAN NOT NULL DEFAULT false,
  "countryCode" TEXT NOT NULL DEFAULT 'IR',
  "city" TEXT NOT NULL,
  "area" TEXT,
  "images" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  "status" "ClassifiedAdStatus" NOT NULL DEFAULT 'ACTIVE',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "ClassifiedAd_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ClassifiedAd_countryCode_city_category_status_idx" ON "ClassifiedAd"("countryCode", "city", "category", "status");
CREATE INDEX "ClassifiedAd_status_createdAt_idx" ON "ClassifiedAd"("status", "createdAt");
ALTER TABLE "ClassifiedAd" ADD CONSTRAINT "ClassifiedAd_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
