
class StripeConfig {
  static const publishableKey = 'pk_test_51S8DVA3pBxs4GQq6hneXGr3bCfmh5XMnaDehSGxA7TIzGHc2Gq04gzFHKNYZeRcIU6zsA1BXkEQG7AiObEMeOHwl00ptgOsedD';
  static const secretKey = 'sk_test_51S8DVA3pBxs4GQq6miyeVaxVlQnHrTZRjv7z3ag4uPrKxMNNvALi6DQQCV2dTYUJfvtYzIIiMIBScXjeyWUTMFp500c504eNaW';

  static const currency = 'usd';

  static const adminFeePercent = 0.20;

  static int applicationFeeCents(double amountMajor) {
    final fee = (amountMajor * adminFeePercent) * 100;
    return fee.round();
  }

  static int amountToCents(double amountMajor) => (amountMajor * 100).round();
}

