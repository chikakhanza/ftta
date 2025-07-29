import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkConfig {
  static http.Client createHttpClient() {
    return http.Client();
  }

  static Map<String, String> getImageHeaders() {
    return {
      'User-Agent': 'Flutter App/1.0',
      'Accept': 'image/*,*/*;q=0.8',
      'Accept-Encoding': 'gzip, deflate',
      'Connection': 'keep-alive',
      'Cache-Control': 'max-age=3600',
    };
  }

  static Duration getTimeout() {
    return const Duration(seconds: 15);
  }

  static Duration getConnectTimeout() {
    return const Duration(seconds: 10);
  }

  static int getRetryCount() {
    return 3;
  }

  static Duration getRetryDelay(int retryCount) {
    return Duration(seconds: retryCount * 2);
  }
} 