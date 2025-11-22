import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../data/payment/payment_service.dart';
import '../data/repository/tailor_repository.dart';

// States
abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}
class PaymentSuccess extends PaymentState {}
class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentService _service;
  final TailorRepository _tailorRepo;

  PaymentCubit(this._service, this._tailorRepo) : super(PaymentInitial());

  Future<void> payWithSdkCard({
    required String orderId,
    required String tailorId,
    required double amountMajor,
  }) async {
    emit(PaymentLoading());
    try {
      final tailor = await _tailorRepo.getTailorById(tailorId);
      final dest = tailor?.stripe_account_id;
      if (dest == null || dest.isEmpty) {
        throw Exception('Tailor is not payment-enabled');
      }

      // Create PaymentIntent
      final pi = await _service.createPaymentIntent(
        amountMajor: amountMajor,
        description: 'Order $orderId',
        destinationAccount: dest,
      );

      // Confirm using Stripe SDK captured card details
      await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: pi.clientSecret,
        data: stripe.PaymentMethodParams.card(
          paymentMethodData: const stripe.PaymentMethodData(),
        ),
      );

      emit(PaymentSuccess());
    } on stripe.StripeException catch (e) {
      emit(PaymentFailure(e.error.message ?? 'Stripe error'));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> payWithPaymentSheet({
    required String orderId,
    required String tailorId,
    required double amountMajor,
  }) async {
    emit(PaymentLoading());
    try {
      final tailor = await _tailorRepo.getTailorById(tailorId);
      final dest = tailor?.stripe_account_id;
      if (dest == null || dest.isEmpty) {
        throw Exception('Tailor is not payment-enabled');
      }

      // Create PaymentIntent
      final pi = await _service.createPaymentIntent(
        amountMajor: amountMajor,
        description: 'Order $orderId',
        destinationAccount: dest,
      );

      // Initialize PaymentSheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: pi.clientSecret,
          merchantDisplayName: 'Stitchanda',
          style: ThemeMode.system,
          googlePay: const stripe.PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
          // No customer ephemeral key in this test-mode, PI-only flow
          allowsDelayedPaymentMethods: false,
        ),
      );

      // Present PaymentSheet (Stripe shows its own bottom sheet UI)
      await stripe.Stripe.instance.presentPaymentSheet();

      emit(PaymentSuccess());
    } on stripe.StripeException catch (e) {
      emit(PaymentFailure(e.error.message ?? 'Stripe error'));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  void reset() => emit(PaymentInitial());
}
