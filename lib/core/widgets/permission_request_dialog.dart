import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionRequestDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onOpenSettings;
  final VoidCallback? onCancel;
  final bool isPermanentlyDenied;

  const PermissionRequestDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onOpenSettings,
    this.onCancel,
    this.isPermanentlyDenied = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        icon,
        size: 48.sp,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (isPermanentlyDenied) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'You need to enable this permission manually in app settings.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onCancel != null)
          TextButton(onPressed: onCancel, child: const Text('Not now')),
        FilledButton(
          onPressed: onOpenSettings,
          child: Text(
            isPermanentlyDenied ? 'Open Settings' : 'Grant Permission',
          ),
        ),
      ],
    );
  }
}
