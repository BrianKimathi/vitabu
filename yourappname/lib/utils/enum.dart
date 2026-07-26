import 'package:flutter/material.dart';

enum AccessType {
  free, // 0
  paid, // 1
  subscription, // 2
}

AccessType accessTypeFromInt(int? value) {
  switch (value) {
    case 1:
      return AccessType.paid;
    case 2:
      return AccessType.subscription;
    case 0:
    default:
      return AccessType.free;
  }
}

AccessType accessTypeFromApi({
  required int? accessType,
  required int? isBuy,
}) {
  if (accessType == 1 && isBuy == 0) return AccessType.paid;
  if (accessType == 2) return AccessType.subscription;
  return AccessType.free;
}

class AccessTypeUI {
  final Color bgColor;
  final Color textColor;
  final String label;

  const AccessTypeUI({
    required this.bgColor,
    required this.textColor,
    required this.label,
  });
}

AccessTypeUI getAccessTypeUI(AccessType type) {
  switch (type) {
    case AccessType.paid:
      return AccessTypeUI(
        bgColor: const Color(0xFFFFD1D1),
        textColor: Colors.red.shade900,
        label: "Buy",
      );

    case AccessType.subscription:
      return AccessTypeUI(
        bgColor: const Color(0xFFD6E4FF),
        textColor: Colors.blue.shade900,
        label: "included",
      );

    case AccessType.free:
      return AccessTypeUI(
        bgColor: const Color(0xFFD1FFD1),
        textColor: Colors.green.shade900,
        label: "free",
      );
  }
}

AccessType getAccessTypeFromApi(int? value) {
  switch (value) {
    case 1:
      return AccessType.paid;
    case 2:
      return AccessType.subscription;
    case 0:
    default:
      return AccessType.free;
  }
}

AccessType resolveAccessType({
  required int? accessType, // API: 0,1,2
  required int? isBuy, // API: 0/1
  required bool isUserSubscribed, // user active subscription?
}) {
  // FREE content
  if (accessType == 0) {
    return AccessType.free;
  }

  // PAID content
  if (accessType == 1) {
    if (isBuy == 1) return AccessType.free;
    return AccessType.paid;
  }

  // SUBSCRIPTION content
  if (accessType == 2) {
    if (isUserSubscribed) return AccessType.free;
    return AccessType.subscription;
  }

  return AccessType.free;
}
