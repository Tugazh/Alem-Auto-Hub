import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

Future<String?> showCitySelectionModal(
  BuildContext context, {
  required List<String> cities,
  String? selectedCity,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shrinkWrap: true,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        ...cities.map(
          (city) => ListTile(
            title: Text(city),
            trailing: city == selectedCity
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(city),
          ),
        ),
      ],
    ),
  );
}
