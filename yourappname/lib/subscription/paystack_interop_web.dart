import 'dart:js' as js;
import 'package:flutter/material.dart';

void openPaystackIframe({
  required BuildContext context,
  required String publicKey,
  required String email,
  required int amountInKobo,
  required String currency,
  required String reference,
  required VoidCallback onSuccess,
  required VoidCallback onCancel,
  String? subaccount,
}) {
  try {
    var paystackPop = js.context['PaystackPop'];
    if (paystackPop == null) {
      debugPrint("PaystackPop is not loaded from index.html");
      onCancel();
      return;
    }

    debugPrint("Paystack Init: key=$publicKey, email=$email, amount=$amountInKobo, currency=$currency, ref=$reference, subaccount=$subaccount");

    final options = {
      'key': publicKey,
      'email': email,
      'amount': amountInKobo,
      'currency': currency,
      'ref': reference,
      'callback': js.JsFunction.withThis((_, response) {
        onSuccess();
      }),
      'onClose': js.JsFunction.withThis((_) {
        onCancel();
      }),
    };

    if (subaccount != null && subaccount.isNotEmpty) {
      options['subaccount'] = subaccount;
    }

    var handler = paystackPop.callMethod('setup', [
      js.JsObject.jsify(options)
    ]);

    handler.callMethod('openIframe');
  } catch (e) {
    debugPrint("Error opening Paystack Popup: $e");
    onCancel();
  }
}
