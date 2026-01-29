// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:romancewhs/UX/global.dart';

Future<void> checkForUpdate() async {
  try {
    final dio = Dio();
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      return client
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
    };
    Fluttertoast.showToast(msg: 'Checking For Updates... on $baseUrl');
    final response = await dio.get('$baseUrl/Update/check');
    final latestVersion = response.data['version'];
    Fluttertoast.showToast(msg: 'Version $latestVersion found');
    final apkUrl = '$baseUrl/Update/download-apk';

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    // Fluttertoast.showToast(msg: 'Current Version $currentVersion');
    if (latestVersion != currentVersion) {
      Fluttertoast.showToast(msg: 'Downloading Update...');
      final shouldUpdate = true;
      if (shouldUpdate == true) {
        final dir = await getExternalStorageDirectory();
        final apkPath = '${dir!.path}/update.apk';
        await dio.download(apkUrl, apkPath);
        Fluttertoast.showToast(msg: 'Updating App...');
        await AppInstaller.installApk(apkPath);
      }
    }
  } catch (ex) {
    Fluttertoast.showToast(msg: 'Error while updating the app');
  }
}
