import 'package:flutter/material.dart';

Future<bool?> showConfirmActionDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Подтвердить',
  String cancelText = 'Отмена',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
