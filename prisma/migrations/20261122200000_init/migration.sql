CREATE TYPE "UserRole" AS ENUM ('CUSTOMER', 'SELLER', 'ADMIN');
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'PENDING');
CREATE TYPE "ListingStatus" AS ENUM ('DRAFT', 'ACTIVE', 'SOLD', 'ARCHIVED');
CREATE TYPE "OrderStatus" AS ENUM ('PENDING', 'PAID', 'FULFILLED', 'CANCELLED', 'REFUNDED');
CREATE TYPE "AiTaskStatus" AS ENUM ('QUEUED', 'RUNNING', 'SUCCEEDED', 'FAILED', 'REVIEW_REQUIRED');

CREATE TABLE "User" (
  "id" TEXT NOT NULL,
  "email" TEXT,
  "phone" TEXT,
  "passwordHash" TEXT NOT NULL,
  "displayName" TEXT,
  "username" TEXT,
  "countryCode" TEXT NOT NULL DEFAULT 'IR',
  "locale" TEXT NOT NULL DEFAULT 'fa-IR',
  "role" "UserRole" NOT NULL DEFAULT 'CUSTOMER',
  "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Store" (
  "id" TEXT NOT NULL,
  "ownerId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "countryCode" TEXT NOT NULL,
  "defaultCurrency" TEXT NOT NULL DEFAULT 'USD',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Store_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Listing" (
  "id" TEXT NOT NULL,
  "sellerId" TEXT NOT NULL,
  "storeId" TEXT,
  "title" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "price" DECIMAL(18,4) NOT NULL,
  "currency" TEXT NOT NULL DEFAULT 'USD',
  "countryCode" TEXT NOT NULL,
  "locale" TEXT NOT NULL DEFAULT 'en',
  "category" TEXT NOT NULL,
  "status" "ListingStatus" NOT NULL DEFAULT 'DRAFT',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Listing_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Order" (
  "id" TEXT NOT NULL,
  "buyerId" TEXT NOT NULL,
  "sellerId" TEXT NOT NULL,
  "countryCode" TEXT NOT NULL,
  "currency" TEXT NOT NULL,
  "subtotal" DECIMAL(18,4) NOT NULL,
  "status" "OrderStatus" NOT NULL DEFAULT 'PENDING',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Order_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "AiTask" (
  "id" TEXT NOT NULL,
  "taskType" TEXT NOT NULL,
  "status" "AiTaskStatus" NOT NULL DEFAULT 'QUEUED',
  "inputJson" JSONB NOT NULL,
  "outputJson" JSONB,
  "needsReview" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "completedAt" TIMESTAMP(3),
  CONSTRAINT "AiTask_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");
CREATE INDEX "User_countryCode_status_idx" ON "User"("countryCode", "status");
CREATE UNIQUE INDEX "Store_ownerId_key" ON "Store"("ownerId");
CREATE INDEX "Listing_countryCode_category_status_idx" ON "Listing"("countryCode", "category", "status");
CREATE INDEX "Listing_currency_price_idx" ON "Listing"("currency", "price");
CREATE INDEX "Order_buyerId_createdAt_idx" ON "Order"("buyerId", "createdAt");
CREATE INDEX "Order_sellerId_createdAt_idx" ON "Order"("sellerId", "createdAt");
CREATE INDEX "AiTask_status_createdAt_idx" ON "AiTask"("status", "createdAt");

ALTER TABLE "Store" ADD CONSTRAINT "Store_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE SET NULL ON UPDATE CASCADE;
