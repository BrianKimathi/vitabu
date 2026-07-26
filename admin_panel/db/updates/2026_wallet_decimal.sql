-- Run on production if wallet_amount is still INT (fractional author earnings were truncated).
ALTER TABLE `tbl_user`
  MODIFY COLUMN `wallet_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00;
