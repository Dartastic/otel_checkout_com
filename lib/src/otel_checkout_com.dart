// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_checkout_com_suppression.dart';

class CheckoutComResult {
  const CheckoutComResult({
    this.processingChannelId,
    this.paymentId,
    this.paymentMethod,
    this.scheme,
    this.amount,
    this.currency,
    this.status,
    this.responseCode,
    this.threeDS,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? processingChannelId;
  final String? paymentId;
  final String? paymentMethod;
  final String? scheme;
  final double? amount;
  final String? currency;
  final String? status;
  final String? responseCode;
  final bool? threeDS;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class CheckoutComCallResult<T> {
  const CheckoutComCallResult({required this.value, this.result});
  final T value;
  final CheckoutComResult? result;
}

Future<T> tracedCheckoutCom<T>({
  required String operation,
  required Future<CheckoutComCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (checkoutComInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_checkout_com');
  final span = t.startSpan('checkoutcom $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'checkout_com');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.processingChannelId != null) {
        span.setStringAttribute(
          'checkoutcom.processing_channel.id',
          res.processingChannelId!,
        );
      }
      if (res.paymentId != null) {
        span.setStringAttribute('checkoutcom.payment.id', res.paymentId!);
      }
      if (res.paymentMethod != null) {
        span.setStringAttribute(
          'checkoutcom.payment_method',
          res.paymentMethod!,
        );
      }
      if (res.scheme != null) {
        span.setStringAttribute('checkoutcom.scheme', res.scheme!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('checkoutcom.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('checkoutcom.currency', res.currency!);
      }
      if (res.status != null) {
        span.setStringAttribute('checkoutcom.status', res.status!);
      }
      if (res.responseCode != null) {
        span.setStringAttribute('checkoutcom.response_code', res.responseCode!);
      }
      if (res.threeDS != null) {
        span.setBoolAttribute('checkoutcom.three_ds', res.threeDS!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('checkoutcom.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'checkout_com.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
