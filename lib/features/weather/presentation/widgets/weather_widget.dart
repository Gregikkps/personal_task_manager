import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_task_manager/core/services/permission_service.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'package:personal_task_manager/core/widgets/permission_request_dialog.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  void _showPermissionDialog(BuildContext context, WeatherViewModel vm) {
    final isPermanent =
        vm.permissionStatus == LocationPermissionStatus.deniedForever;
    final isServiceDisabled =
        vm.permissionStatus == LocationPermissionStatus.serviceDisabled;

    showDialog(
      context: context,
      builder: (context) => PermissionRequestDialog(
        title: isServiceDisabled
            ? 'Location Services Disabled'
            : 'Location Permission Required',
        description: isServiceDisabled
            ? 'Please enable location services in your device settings to see weather information.'
            : isPermanent
            ? 'Weather features require location access. Please enable location permission in app settings.'
            : 'We need your location to show weather information for your area.',
        icon: isServiceDisabled ? Icons.location_off : Icons.location_on,
        isPermanentlyDenied: isPermanent,
        onOpenSettings: () async {
          Navigator.of(context).pop();
          await vm.openSettings();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    final basePadding = EdgeInsets.all(12.w);
    final decoration = BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(12),
    );

    if (vm.isLoading) {
      return Container(
        padding: basePadding,
        decoration: decoration,
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(),
            ),
            SizedBox(width: 12.w),
            Text(
              'Loading weather...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (vm.needsPermission) {
      return InkWell(
        onTap: () => _showPermissionDialog(context, vm),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: basePadding,
          decoration: decoration.copyWith(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Weather unavailable',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Tap to enable location',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      );
    }

    if (vm.errorMessage != null) {
      return Container(
        padding: basePadding,
        decoration: decoration,
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () => vm.loadWeather(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    final weather = vm.weather;
    if (weather == null) {
      return Container(
        padding: basePadding,
        decoration: decoration,
        child: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.grey),
            SizedBox(width: 12),
            Text('Unknown location', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      padding: basePadding,
      decoration: decoration,
      child: Row(
        children: [
          Image.network(
            weather.conditionIconUrl,
            width: 48.w,
            height: 48.h,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.cloud, size: 48.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weather.locationName,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${weather.temperatureC.round()}°C',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  weather.conditionText,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
