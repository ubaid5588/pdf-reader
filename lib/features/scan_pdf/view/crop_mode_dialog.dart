import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CropModeDialog extends StatefulWidget {
  const CropModeDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CropModeDialog(),
    );
  }

  @override
  State<CropModeDialog> createState() => _CropModeDialogState();
}

class _CropModeDialogState extends State<CropModeDialog> {
  final ScanPdfController controller = Get.find<ScanPdfController>();
  late bool _autoCrop;
  late bool _dontAskAgain;

  @override
  void initState() {
    super.initState();
    _autoCrop = controller.autoCropPreference.value;
    _dontAskAgain = controller.dontAskCropModeAgain.value;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose crop mode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "You can change it in 'Settings - Scan settings' at any time.",
              style: TextStyle(
                fontSize: 12.5,
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            // Option 1: Auto crop
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _autoCrop = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _autoCrop
                      ? const Color(0xFF2563EB).withOpacity(0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _autoCrop
                        ? const Color(0xFF2563EB)
                        : colors.border.withOpacity(0.6),
                    width: _autoCrop ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.crop_free_rounded,
                      color: _autoCrop
                          ? const Color(0xFF2563EB)
                          : colors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto crop',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _autoCrop
                                  ? const Color(0xFF2563EB)
                                  : colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Automatically detects document boundaries',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<bool>(
                      value: true,
                      groupValue: _autoCrop,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) => setState(() => _autoCrop = val!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Option 2: No crop
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _autoCrop = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: !_autoCrop
                      ? const Color(0xFF2563EB).withOpacity(0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: !_autoCrop
                        ? const Color(0xFF2563EB)
                        : colors.border.withOpacity(0.6),
                    width: !_autoCrop ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fullscreen_rounded,
                      color: !_autoCrop
                          ? const Color(0xFF2563EB)
                          : colors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No crop',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: !_autoCrop
                                  ? const Color(0xFF2563EB)
                                  : colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Keeps the full original image',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<bool>(
                      value: false,
                      groupValue: _autoCrop,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) => setState(() => _autoCrop = val!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Footer Checkbox: Don't ask again
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _dontAskAgain = !_dontAskAgain),
              child: Row(
                children: [
                  Checkbox(
                    value: _dontAskAgain,
                    activeColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) => setState(() => _dontAskAgain = val ?? false),
                  ),
                  Text(
                    "Don't ask again",
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Button: Next
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  controller.autoCropPreference.value = _autoCrop;
                  controller.dontAskCropModeAgain.value = _dontAskAgain;
                  Get.back(result: _autoCrop);
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
