// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_checkout_com/otel_checkout_com.dart';

/// Traces Checkout Com calls with OpenTelemetry.
///
/// `otel_checkout_com` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Checkout Com call in
/// [tracedCheckoutCom]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'checkout-com-example');

  // Traces a Checkout Com call.
  final checkoutComId = await tracedCheckoutCom<String>(
    operation: 'create',
    invoke: () async {
      // Make the Checkout Com call here, then report what it returned.
      const id = 'checkout_com_8f3a2c';
      return const CheckoutComCallResult(
          value: id,
          result: CheckoutComResult(
              processingChannelId: 'processingchannel_8f3a2c',
              paymentId: 'payment_8f3a2c',
              paymentMethod: 'card',
              scheme: 'example',
              amount: 0.5,
              currency: 'usd',
              status: 'succeeded',
              responseCode: 'example',
              threeDS: true,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedCheckoutCom create returned $checkoutComId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCheckoutComInstrumentationAsync.
  await runWithoutCheckoutComInstrumentationAsync(
    () => tracedCheckoutCom<String>(
      operation: 'create',
      invoke: () async {
        const id = 'checkout_com_8f3a2c';
        return const CheckoutComCallResult(
            value: id,
            result: CheckoutComResult(
                processingChannelId: 'processingchannel_8f3a2c',
                paymentId: 'payment_8f3a2c',
                paymentMethod: 'card',
                scheme: 'example',
                amount: 0.5,
                currency: 'usd',
                status: 'succeeded',
                responseCode: 'example',
                threeDS: true,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
