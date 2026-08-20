import 'dart:io';

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PdfFileTile extends StatelessWidget {
  final File? file;
  final String? name;
  final int? size;
  final DateTime? date;
  final String? subtitle;
  final bool isSelected;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? contentPadding;

  const PdfFileTile({
    super.key,
    this.file,
    this.name,
    this.size,
    this.date,
    this.subtitle,
    this.isSelected = false,
    this.trailing,
    this.showArrow = false,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
  });

  String _formatSubtitle({int? bytes, DateTime? modifiedDate}) {
    String formatted = '';
    if (bytes != null && bytes > 0) {
      formatted += RecentPdfController.formatBytes(bytes);
    }
    if (modifiedDate != null) {
      final dateFormatted = DateFormat('MMM d, yyyy').format(modifiedDate);
      if (formatted.isNotEmpty) {
        formatted += ' • $dateFormatted';
      } else {
        formatted = dateFormatted;
      }
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final String fileName = name ??
        (file != null ? file!.path.split(Platform.pathSeparator).last : 'Untitled.pdf');

    Widget? trailingWidget = trailing;
    if (trailingWidget == null && showArrow) {
      trailingWidget = Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: colors.textSecondary.withOpacity(0.5),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary
                : (colors.isDark
                    ? const Color(0xFF3B1E1E)
                    : const Color(0xFFFFEBEE)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isSelected
              ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                )
              : Icon(
                  Icons.picture_as_pdf_rounded,
                  color: colors.isDark
                      ? const Color(0xFFF87171)
                      : const Color(0xFFEF5350),
                  size: 22,
                ),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? colors.primary : colors.textPrimary,
          ),
        ),
        subtitle: _buildSubtitle(colors),
        trailing: trailingWidget,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget? _buildSubtitle(AppColors colors) {
    // 1. Direct subtitle override
    if (subtitle != null && subtitle!.isNotEmpty) {
      return Text(
        subtitle!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          color: colors.textSecondary,
        ),
      );
    }

    // 2. Pre-supplied size or date
    if (size != null || date != null) {
      final formatted = _formatSubtitle(bytes: size, modifiedDate: date);
      if (formatted.isEmpty) return null;
      return Text(
        formatted,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          color: colors.textSecondary,
        ),
      );
    }

    // 3. Resolve from File asynchronously if available
    if (file != null) {
      return FutureBuilder<FileStat>(
        future: file!.stat(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final stat = snapshot.data!;
            final formatted = _formatSubtitle(
              bytes: stat.size,
              modifiedDate: stat.modified,
            );
            if (formatted.isNotEmpty) {
              return Text(
                formatted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.textSecondary,
                ),
              );
            }
          }
          return Text(
            'Loading...',
            style: TextStyle(
              fontSize: 11.5,
              color: colors.textSecondary,
            ),
          );
        },
      );
    }

    return null;
  }
}
