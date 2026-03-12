import 'dart:io';

import 'package:attendance_system/services/leave/leave_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Downloader {

  final void Function(int receivedBytes, int totalBytes)? onProgress;
  final void Function()? onDownloadSuccess;
  final void Function()? onDownloadStart;
  final void Function(dynamic e)? onError;

  const Downloader({this.onProgress, this.onDownloadSuccess, this.onDownloadStart, this.onError});

  Future<void> downloadFile(NetworkFile file) async {
    if (kIsWeb) {
      final Uri uri = Uri.parse(file.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      try {
        // 1. หาโฟลเดอร์ชั่วคราว (Temp Directory)
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = '${tempDir.path}/${file.fileName}';

        File tempFile = File(tempPath);
        bool shouldDownload = true;

        if (await tempFile.exists()) {
          int localSize = await tempFile.length();

          if (localSize == file.fileSize) {
            shouldDownload = false;
          }
        }

        if (shouldDownload) {
          onDownloadStart?.call();
          Dio dio = Dio();
          await dio.download(
            file.fileUrl,
            tempPath,
            onReceiveProgress: (receivedBytes, totalBytes) {
              if (totalBytes != -1) {
                onProgress?.call(receivedBytes, totalBytes);
              }
            },
            deleteOnError: true,
          );

          onDownloadSuccess?.call();
        }

        final xFile = XFile(tempPath);

        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            subject: file.fileName,
          ),
        );

      } catch (e) {
        onError?.call(e);
      }
    }
  }
}