# otel_checkout_com

Dartastic OpenTelemetry bridge for Checkout.com (global payments).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_checkout_com/otel_checkout_com.dart';

await tracedCheckoutCom<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return CheckoutComCallResult(value: r, result: CheckoutComResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutCheckoutComInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
