import 'package:flutter/material.dart';

/// A simple, reusable confirmation dialog that works in any Flutter app.
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ConfirmationDialog(
///     icon: Icons.warning,
///     title: "Delete Item",
///     description: "Are you sure you want to delete this item?",
///     onConfirm: () {
///       // Handle confirmation
///     },
///   ),
/// );
/// ```
class ConfirmationDialog extends StatelessWidget {
  /// Icon to display at the top (can be [IconData] or [ImageProvider]).
  final dynamic icon;

  /// Optional title text.
  final String? title;

  /// Main description message.
  final String description;

  /// Called when the user presses "Confirm" or "Yes".
  final VoidCallback onConfirm;

  /// Optional callback when pressing "Cancel".
  final VoidCallback? onCancel;

  /// Optional button text override.
  final String confirmText;
  final String cancelText;

  /// Optional flag to show/hide the Cancel button.
  final bool showCancelButton;

  /// Icon size.
  final double iconSize;

  /// Colors and theming
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    this.showCancelButton = true,
    this.iconSize = 60,
    this.confirmButtonColor,
    this.cancelButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon or image
            if (icon != null) ...[
              icon is IconData
                  ? Icon(icon, size: iconSize, color: theme.primaryColor)
                  : Image(
                image: icon as ImageProvider,
                height: iconSize,
                width: iconSize,
              ),
              const SizedBox(height: 16),
            ],

            // Title
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                if (showCancelButton)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        cancelButtonColor ?? theme.colorScheme.secondary,
                        side: BorderSide(
                          color: cancelButtonColor ??
                              theme.colorScheme.secondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onCancel ?? () => Navigator.pop(context),
                      child: Text(cancelText),
                    ),
                  ),
                if (showCancelButton) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      confirmButtonColor ?? theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      onConfirm();
                    },
                    child: Text(confirmText,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
