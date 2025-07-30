import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/homestay_model.dart';
import '../models/booking_model.dart';

class ApiService {
  static const baseUrl = 'http://10.41.30.252:8000/api';

  static Future<List<Homestay>> fetchHomestays() async {
    final response = await http.get(Uri.parse('$baseUrl/homestays'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Homestay.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data homestay');
    }
  }

  static Future<List<Booking>> fetchBookings(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings?user_id=$userId'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat riwayat booking');
    }
  }

  static Future<void> createBooking(Booking booking) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(booking.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal membuat booking');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  static Future<bool> checkAvailability({
    required int homestayId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int jumlahKamar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-availability'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'homestay_id': homestayId,
        'check_in': checkIn.toIso8601String(),
        'check_out': checkOut.toIso8601String(),
        'jumlah_kamar': jumlahKamar,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['available'] == true;
    } else {
      throw Exception('Gagal cek ketersediaan kamar');
    }
  }

  static Future<bool> cancelBooking(int bookingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> payBooking(int bookingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$bookingId/pay'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
