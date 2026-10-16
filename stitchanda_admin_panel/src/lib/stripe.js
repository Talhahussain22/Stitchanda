import Stripe from 'stripe';

const stripeKey = import.meta.env.VITE_STRIPE_SECRET_KEY;

// No key yet: the functions below return empty data instead of calling Stripe
export const isStripeConfigured = Boolean(stripeKey);

let stripeClient = null;

const getStripe = () => {
  if (!stripeClient) {
    stripeClient = new Stripe(stripeKey);
  }
  return stripeClient;
};

const EMPTY_STATISTICS = {
  totalRevenue: 0,
  refundedAmount: 0,
  netRevenue: 0,
  totalTransactions: 0,
  successfulPayments: 0,
  failedPayments: 0,
  pendingPayments: 0,
};

export const getStripeBalance = async () => {
  if (!isStripeConfigured) return null;
  try {
    const stripe = getStripe();
    const balance = await stripe.balance.retrieve();
    return balance;
  } catch (error) {
    console.error('Error fetching Stripe balance:', error);
    throw error;
  }
};


export const getStripePayments = async (limit = 100) => {
  if (!isStripeConfigured) return [];
  try {
    const stripe = getStripe();
    const charges = await stripe.charges.list({
      limit: limit,
    });

    return charges.data.map(charge => ({
      id: charge.id,
      amount: charge.amount / 100, 
      currency: charge.currency.toUpperCase(),
      status: charge.status, 
      paid: charge.paid,
      customerEmail: charge.billing_details?.email || charge.receipt_email,
      customerName: charge.billing_details?.name || '-',
      description: charge.description,
      created: new Date(charge.created * 1000),
      paymentMethod: charge.payment_method_details?.type || '-',
      receiptUrl: charge.receipt_url,
    }));
  } catch (error) {
    console.error('Error fetching Stripe payments:', error);
    throw error;
  }
};

export const getTotalRevenue = async () => {
  if (!isStripeConfigured) return 0;
  try {
    const stripe = getStripe();
    let totalRevenue = 0;
    let hasMore = true;
    let startingAfter = null;

    while (hasMore) {
      const params = {
        limit: 100,
        ...(startingAfter && { starting_after: startingAfter })
      };

      const charges = await stripe.charges.list(params);

      charges.data.forEach(charge => {
        if (charge.status === 'succeeded' && charge.paid) {
          totalRevenue += charge.amount;
        }
      });

      hasMore = charges.has_more;
      if (hasMore && charges.data.length > 0) {
        startingAfter = charges.data[charges.data.length - 1].id;
      }
    }

    return totalRevenue / 100;
  } catch (error) {
    console.error('Error calculating total revenue:', error);
    throw error;
  }
};

export const getPaymentStatistics = async () => {
  if (!isStripeConfigured) return { ...EMPTY_STATISTICS };
  try {
    const stripe = getStripe();
    const charges = await stripe.charges.list({ limit: 100 });

    let totalRevenue = 0;
    let successfulPayments = 0;
    let failedPayments = 0;
    let pendingPayments = 0;
    let refundedAmount = 0;

    charges.data.forEach(charge => {
      if (charge.status === 'succeeded' && charge.paid) {
        totalRevenue += charge.amount;
        successfulPayments++;
      } else if (charge.status === 'failed') {
        failedPayments++;
      } else if (charge.status === 'pending') {
        pendingPayments++;
      }

      if (charge.refunded) {
        refundedAmount += charge.amount_refunded;
      }
    });

    return {
      totalRevenue: totalRevenue / 100,
      refundedAmount: refundedAmount / 100,
      netRevenue: (totalRevenue - refundedAmount) / 100,
      totalTransactions: charges.data.length,
      successfulPayments,
      failedPayments,
      pendingPayments,
    };
  } catch (error) {
    console.error('Error fetching payment statistics:', error);
    throw error;
  }
};


export const getPaymentById = async (chargeId) => {
  if (!isStripeConfigured) return null;
  try {
    const stripe = getStripe();
    const charge = await stripe.charges.retrieve(chargeId);
    return {
      id: charge.id,
      amount: charge.amount / 100,
      currency: charge.currency.toUpperCase(),
      status: charge.status,
      paid: charge.paid,
      customerEmail: charge.billing_details?.email || charge.receipt_email,
      customerName: charge.billing_details?.name || '-',
      description: charge.description,
      created: new Date(charge.created * 1000),
      paymentMethod: charge.payment_method_details?.type || '-',
      receiptUrl: charge.receipt_url,
    };
  } catch (error) {
    console.error('Error fetching payment:', error);
    throw error;
  }
};
