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
  throw UnsupportedError("Cannot load web JS on this platform.");
}
