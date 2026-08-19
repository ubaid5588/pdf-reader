import 'dart:io';

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/core/widgets/custom_button.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

enum ConversionFlowState { processing, completed, error }

class ConversionProcessingPage extends StatefulWidget {
  final String title;
  final String initialMessage;
  final Future<File?> Function(
    void Function(double progress, String status) onProgress,
  )
  processOperation;
  final VoidCallback? onCancel;

  const ConversionProcessingPage({
    super.key,
    required this.title,
    this.initialMessage = '',
    required this.processOperation,
    this.onCancel,
  });

  @override
  State<ConversionProcessingPage> createState() =>
      _ConversionProcessingPageState();
}

class _ConversionProcessingPageState extends State<ConversionProcessingPage>
    with TickerProviderStateMixin {
  ConversionFlowState _state = ConversionFlowState.processing;
  double _progress = 0.1;
  String _statusMessage = '';
  String _errorMessage = '';
  File? _completedFile;
  String _fileName = '';
  String _fileSize = '';

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _statusMessage = widget.initialMessage;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0.1, end: 0.1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeOperation();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress(double progressValue, String status) {
    if (!mounted) return;
    setState(() {
      _statusMessage = status;
      final targetProgress = progressValue.clamp(0.05, 1.0);
      _progressAnimation = Tween<double>(begin: _progress, end: targetProgress)
          .animate(
            CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
          );
      _progress = targetProgress;
    });
    _progressController.forward(from: 0.0);
  }

  Future<void> _executeOperation() async {
    if (!mounted) return;
    setState(() {
      _state = ConversionFlowState.processing;
      _progress = 0.1;
      _statusMessage = widget.initialMessage;
      _errorMessage = '';
      _completedFile = null;
    });

    try {
      final result = await widget.processOperation(_updateProgress);

      if (!mounted) return;

      if (result != null && await result.exists()) {
        final name = result.path.split(Platform.pathSeparator).last;
        int bytes = 0;
        try {
          bytes = await result.length();
        } catch (_) {}

        final formattedSize = RecentPdfController.formatBytes(bytes);

        // Record in recent controller and refresh files
        try {
          final recentController = Get.isRegistered<RecentPdfController>()
              ? Get.find<RecentPdfController>()
              : Get.put(RecentPdfController());
          await recentController.addRecentPdf(result.path, name);

          if (Get.isRegistered<FilePageController>()) {
            await Get.find<FilePageController>().refreshPdfs();
          }
        } catch (_) {}

        setState(() {
          _completedFile = result;
          _fileName = name;
          _fileSize = formattedSize;
          _progress = 1.0;
          _state = ConversionFlowState.completed;
        });
      } else {
        setState(() {
          _errorMessage = 'No output file was generated.';
          _state = ConversionFlowState.error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _state = ConversionFlowState.error;
      });
    }
  }

  String _getPhaseTitle(AppLocalizations lang, double pct) {
    if (pct < 0.35) return lang.preparing;
    if (pct < 0.80) return lang.converting;
    return lang.almostDone;
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final colors = context.colors;
    final int percentage = (_progress * 100).toInt();

    return WillPopScope(
      onWillPop: () async {
        if (_state == ConversionFlowState.processing) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: colors.surfaceElevated,
              title: Text(lang.cancel, style: TextStyle(color: colors.textPrimary)),
              content: Text(
                'A conversion is currently in progress. Are you sure you want to exit?',
                style: TextStyle(color: colors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(lang.cancel, style: TextStyle(color: colors.textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colors.textPrimary),
            onPressed: () {
              if (_state == ConversionFlowState.processing) {
                Navigator.of(context).maybePop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated State Switcher
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: _buildCurrentStateView(context, lang, percentage),
                ),

                const SizedBox(height: 48),

                // Bottom Buttons based on state
                _buildBottomActions(context, lang),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStateView(
    BuildContext context,
    AppLocalizations lang,
    int percentage,
  ) {
    switch (_state) {
      case ConversionFlowState.processing:
        return _buildProcessingView(context, lang, percentage);
      case ConversionFlowState.completed:
        return _buildCompletedView(context, lang);
      case ConversionFlowState.error:
        return _buildErrorView(context, lang);
    }
  }

  Widget _buildProcessingView(
    BuildContext context,
    AppLocalizations lang,
    int percentage,
  ) {
    final colors = context.colors;

    return Column(
      key: const ValueKey('processing_view'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Radial Progress Graphic
        SizedBox(
          width: double.infinity,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Soft Glow Ring
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 180 + (_pulseController.value * 12),
                    height: 180 + (_pulseController.value * 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withOpacity(
                        0.12 * (1 - _pulseController.value * 0.5),
                      ),
                    ),
                  );
                },
              ),

              // Background Circular Track with Smooth Animation
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 165,
                    height: 165,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 11,
                      backgroundColor: colors.isDark
                          ? const Color(0xFF1E2030)
                          : const Color(0xFFE0E7FF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  );
                },
              ),

              // Center File Icon & Percentage
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.isDark
                          ? const Color(0xFF1E2438)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      size: 32,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Phase Title
        Text(
          _getPhaseTitle(lang, _progress),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        // Live Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _statusMessage.isNotEmpty
                ? _statusMessage
                : lang.finalizingFileMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Bottom Linear Progress Indicator with Smooth Animation
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 220,
                height: 6,
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: colors.isDark
                      ? const Color(0xFF1E2030)
                      : const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompletedView(BuildContext context, AppLocalizations lang) {
    final colors = context.colors;

    return Column(
      key: const ValueKey('completed_view'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Green Success Badge
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: colors.isDark
                ? const Color(0xFF0F382A)
                : const Color(0xFFD1FAE5),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.success.withOpacity(0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.success.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.check_rounded,
            color: colors.success,
            size: 46,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          lang.conversionComplete,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          lang.yourPdfIsReady,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),

        const SizedBox(height: 28),

        // File Details Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // PDF Badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.isDark
                      ? const Color(0xFF3B1E1E)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'PDF',
                    style: TextStyle(
                      color: colors.isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // File name & info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_fileSize · Just now',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Success check circle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.isDark
                      ? const Color(0xFF0F382A)
                      : const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: colors.success,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, AppLocalizations lang) {
    final colors = context.colors;

    return Column(
      key: const ValueKey('error_view'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.isDark
                ? const Color(0xFF3B1E1E)
                : const Color(0xFFFEE2E2),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.error.withOpacity(0.4),
              width: 2.5,
            ),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: colors.error,
            size: 44,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          lang.conversionFailed,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _errorMessage.isNotEmpty
                ? _errorMessage
                : 'An unexpected error occurred during processing.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, AppLocalizations lang) {
    final colors = context.colors;

    switch (_state) {
      case ConversionFlowState.processing:
        return Text(
          lang.keepAppOpen,
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        );

      case ConversionFlowState.completed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Open PDF Button
            CustomButton(
              text: lang.openPdf,
              width: double.infinity,
              onPressed: () {
                if (_completedFile != null) {
                  Get.to(() => PdfViewer(filePath: _completedFile!));
                }
              },
            ),
            const SizedBox(height: 12),
            // Secondary Share and Done row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: colors.border),
                    ),
                    icon: Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: colors.textPrimary,
                    ),
                    label: Text(
                      lang.share,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      if (_completedFile != null) {
                        try {
                          await Share.shareXFiles([
                            XFile(_completedFile!.path),
                          ]);
                        } catch (e) {
                          Get.snackbar('Share Error', e.toString());
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.surfaceElevated,
                      foregroundColor: colors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                    onPressed: () {
                      Get.until((route) => route.isFirst);
                    },
                    child: Text(
                      lang.done,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case ConversionFlowState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: lang.retry,
              width: double.infinity,
              onPressed: _executeOperation,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                lang.cancel,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
    }
  }
}
