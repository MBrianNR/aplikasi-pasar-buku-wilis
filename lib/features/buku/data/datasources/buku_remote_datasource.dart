import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/utils/api_exception.dart';
import '../models/buku_model.dart';

abstract class BukuRemoteDataSource {
  Future<List<BukuModel>> getBuku();
  Future<BukuModel> createBuku(BukuModel buku);
}

class BukuRemoteDataSourceImpl implements BukuRemoteDataSource {
  final http.Client client;

  BukuRemoteDataSourceImpl({http.Client? client}) : client = client ?? http.Client();

  /// URL API backend. Bisa diganti saat run dengan --dart-define=API_URL=...
  String get baseUrl {
    const dariEnv = String.fromEnvironment('API_URL');
    final server = dariEnv.isNotEmpty
        ? dariEnv.replaceAll(RegExp(r'/+$'), '')
        : 'https://admin-pasar-buku-wilis-zp6q.vercel.app';
    return server.endsWith('/api') ? server : '$server/api';
  }

  Future<http.Response> _kirim(Future<http.Response> Function() panggil) async {
    try {
      return await panggil().timeout(const Duration(seconds: 8));
    } catch (_) {
      throw ApiException('Tidak bisa terhubung ke server ($baseUrl). Pastikan backend sudah berjalan.');
    }
  }

  dynamic _urai(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      body = null;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final pesan = (body is Map && body['message'] is String)
          ? body['message'] as String
          : 'Permintaan gagal (${res.statusCode}).';
      throw ApiException(pesan);
    }
    return body;
  }

  @override
  Future<List<BukuModel>> getBuku() async {
    final res = await _kirim(
      () => client.get(Uri.parse('$baseUrl/buku?limit=100')),
    );
    final body = _urai(res);
    if (body is! Map<String, dynamic> || body['data'] is! List) {
      throw const ApiException('Format data buku dari server tidak sesuai.');
    }
    return (body['data'] as List)
        .map((e) => BukuModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BukuModel> createBuku(BukuModel b) async {
    throw const ApiException(
      'Penambahan buku dilakukan melalui website admin.',
    );
  }
}
