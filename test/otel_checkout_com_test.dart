// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_checkout_com/otel_checkout_com.dart';
import 'package:test/test.dart';

void main() {
  group('otel_checkout_com', () {
    test('suppression toggles in zone', () async {
      expect(checkoutComInstrumentationSuppressed(), isFalse);
      await runWithoutCheckoutComInstrumentationAsync(() async {
        expect(checkoutComInstrumentationSuppressed(), isTrue);
      });
      expect(checkoutComInstrumentationSuppressed(), isFalse);
    });

    test('CheckoutComResult fields default null', () {
      const r = CheckoutComResult();
      expect(r.statusCode, isNull);
    });
  });
}
