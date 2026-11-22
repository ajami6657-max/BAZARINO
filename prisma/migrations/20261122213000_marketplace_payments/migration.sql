CREATE TYPE "PaymentStatus" AS ENUM ('INITIATED', 'PENDING', 'PAID', 'FAILED', 'REFUNDED', 'PARTIALLY_REFUNDED');
CREATE TYPE "PayoutStatus" AS ENUM ('PENDING', 'PROCESSING', 'PAID', 'FAILED', 'CANCELLED');

CREATE TABLE "Payment" (
  "id" TEXT NOT NULL,
  "orderId" TEXT NOT NULL,
  "buyerId" TEXT NOT NULL,
  "sellerId" TEXT NOT NULL,
  "gatewayCode" TEXT NOT NULL,
  "providerPaymentId" TEXT,
  "idempotencyKey" TEXT NOT NULL,
  "currency" TEXT NOT NULL,
  "grossAmount" DECIMAL(18,4) NOT NULL,
  "commissionBps" INTEGER NOT NULL DEFAULT 200,
  "platformFee" DECIMAL(18,4) NOT NULL,
  "sellerNet" DECIMAL(18,4) NOT NULL,
  "status" "PaymentStatus" NOT NULL DEFAULT 'INITIATED',
  "checkoutUrl" TEXT,
  "providerMetadata" JSONB,
  "paidAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "SellerPayoutAccount" (
  "id" TEXT NOT NULL,
  "sellerId" TEXT NOT NULL,
  "providerCode" TEXT NOT NULL,
  "providerBeneficiaryId" TEXT NOT NULL,
  "accountLast4" TEXT,
  "currency" TEXT NOT NULL,
  "countryCode" TEXT NOT NULL,
  "isDefault" BOOLEAN NOT NULL DEFAULT false,
  "verifiedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SellerPayoutAccount_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "SellerPayout" (
  "id" TEXT NOT NULL,
  "paymentId" TEXT NOT NULL,
  "sellerId" TEXT NOT NULL,
  "payoutAccountId" TEXT NOT NULL,
  "amount" DECIMAL(18,4) NOT NULL,
  "currency" TEXT NOT NULL,
  "providerRef" TEXT,
  "status" "PayoutStatus" NOT NULL DEFAULT 'PENDING',
  "failureReason" TEXT,
  "paidAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "SellerPayout_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Payment_orderId_key" ON "Payment"("orderId");
CREATE UNIQUE INDEX "Payment_providerPaymentId_key" ON "Payment"("providerPaymentId");
CREATE UNIQUE INDEX "Payment_idempotencyKey_key" ON "Payment"("idempotencyKey");
CREATE INDEX "Payment_sellerId_status_createdAt_idx" ON "Payment"("sellerId", "status", "createdAt");
CREATE INDEX "Payment_buyerId_createdAt_idx" ON "Payment"("buyerId", "createdAt");
CREATE UNIQUE INDEX "SellerPayoutAccount_sellerId_providerCode_providerBeneficiaryId_key" ON "SellerPayoutAccount"("sellerId", "providerCode", "providerBeneficiaryId");
CREATE INDEX "SellerPayoutAccount_sellerId_isDefault_idx" ON "SellerPayoutAccount"("sellerId", "isDefault");
CREATE UNIQUE INDEX "SellerPayout_providerRef_key" ON "SellerPayout"("providerRef");
CREATE INDEX "SellerPayout_sellerId_status_createdAt_idx" ON "SellerPayout"("sellerId", "status", "createdAt");

ALTER TABLE "Payment" ADD CONSTRAINT "Payment_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_buyerId_fkey" FOREIGN KEY ("buyerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "SellerPayoutAccount" ADD CONSTRAINT "SellerPayoutAccount_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "SellerPayout" ADD CONSTRAINT "SellerPayout_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "Payment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "SellerPayout" ADD CONSTRAINT "SellerPayout_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "SellerPayout" ADD CONSTRAINT "SellerPayout_payoutAccountId_fkey" FOREIGN KEY ("payoutAccountId") REFERENCES "SellerPayoutAccount"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
