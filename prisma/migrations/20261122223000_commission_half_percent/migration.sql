-- New payments use the updated 0.5% platform commission by default.
-- Existing payment rows keep their original checkout-time commission snapshot.
ALTER TABLE "Payment" ALTER COLUMN "commissionBps" SET DEFAULT 50;
