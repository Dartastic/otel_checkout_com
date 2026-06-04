// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'checkout_com')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.processingChannelId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            'checkoutcom.processing_channel.id',
            res.processingChannelId!,
          )
        ]));
      }
      if (res.paymentId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('checkoutcom.payment.id', res.paymentId!)]));
      }
      if (res.paymentMethod != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            'checkoutcom.payment_method',
            res.paymentMethod!,
          )
        ]));
      }
      if (res.scheme != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('checkoutcom.scheme', res.scheme!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('checkoutcom.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('checkoutcom.currency', res.currency!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('checkoutcom.status', res.status!)]));
      }
      if (res.responseCode != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('checkoutcom.response_code', res.responseCode!)
        ]));
      }
      if (res.threeDS != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeBool('checkoutcom.three_ds', res.threeDS!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('checkoutcom.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'checkout_com.error',
          )
        ]));
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
