import 'dart:io';

import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FilePage extends StatelessWidget {
  FilePage({super.key});

  final FilePageController controller = Get.find();

  Future<DateTime> getDate(File file) async {
    final DateTime dateOfFile = await file.lastModified();
    return dateOfFile;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final lang = AppLocalizations.of(context)!;
    return Column(
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.pdfFiles.isEmpty) {
            return Center(child: Text(lang.file));
          }
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: controller.pdfFiles.length,
              itemBuilder: (context, index) {
                final file = controller.pdfFiles[index];

                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        height: size.height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Image.asset(
                          'assets/images/pdf_logo.png',
                          width: size.width * 0.12,
                        ),
                      ),
                      title: Text(file.path.split('/').last),
                      subtitle: FutureBuilder<DateTime>(
                        future: getDate(file),
                        builder:
                            (
                              BuildContext context,
                              AsyncSnapshot<DateTime> snapshot,
                            ) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading date...');
                              }
                              if (snapshot.hasError) {
                                return const Text('Error loading date');
                              }

                              if (snapshot.hasData && snapshot.data != null) {
                                return Text(
                                  DateFormat(
                                    'dd-mm-yyyy hh:mm:a',
                                  ).format(snapshot.data!),
                                );
                              }

                              return const Text('No date found');
                            },
                      ),
                      onTap: () {
                        Get.to(() => PdfViewer(filePath: file));
                      },
                    ),
                    Divider(endIndent: 18, indent: 18),
                  ],
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
