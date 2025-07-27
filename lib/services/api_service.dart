import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/homestay_model.dart';
import '../models/booking_model.dart';

class ApiService {
  static const baseUrl = 'http://localhost:8000/api';

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
}
