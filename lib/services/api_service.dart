import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/homestay_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.244.100.171:8000/api'; // Ganti sesuai backend Anda

  // Ambil data homestay
  static Future<List<Homestay>> fetchHomestays() async {
    try {
      print('Fetching homestays from: $baseUrl/homestays'); // Debug
      final response = await http.get(
        Uri.parse('$baseUrl/homestays'),
        headers: {
          'User-Agent': 'Flutter App',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('Response status code: ${response.statusCode}'); // Debug
      print('Response body: ${response.body}'); // Debug
      
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        
        // Cek apakah response adalah List atau Map
        if (responseData is List) {
          print('Response is a List with ${responseData.length} items'); // Debug
          final homestays = responseData.map((e) => Homestay.fromJson(e)).toList();
          
          // Debug setiap homestay
          for (var homestay in homestays) {
            print(homestay.getDebugInfo());
          }
          
          return homestays;
        } else if (responseData is Map<String, dynamic>) {
          // Jika response adalah Map, cek apakah ada key 'data' atau 'homestays'
          if (responseData.containsKey('data')) {
            final List data = responseData['data'];
            print('Response contains data field with ${data.length} items'); // Debug
            return data.map((e) => Homestay.fromJson(e)).toList();
          } else if (responseData.containsKey('homestays')) {
            final List data = responseData['homestays'];
            print('Response contains homestays field with ${data.length} items'); // Debug
            return data.map((e) => Homestay.fromJson(e)).toList();
          } else {
            print('Response is Map but no data/homestays field found'); // Debug
            return [];
          }
        } else {
          print('Unknown response format'); // Debug
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}'); // Debug
        // Fallback data jika API tidak tersedia
        return []; // Return list kosong jika API gagal
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug
      // Return fallback data jika terjadi error
      return []; // Return list kosong jika terjadi error
    }
  }

  // Test konektivitas ke server foto
  static Future<bool> testImageConnectivity(String imageUrl) async {
    try {
      print('Testing image connectivity: $imageUrl');
      final response = await http.head(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Flutter App',
          'Accept': 'image/*',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Image test response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Image connectivity test failed: $e');
      return false;
    }
  }

  // Ambil riwayat booking user
  static Future<List<Booking>> fetchBookings(int userId) async {
    try {
      print('Fetching bookings for user ID: $userId');
      print('API URL: $baseUrl/bookings?user_id=$userId');
      print('Base URL: $baseUrl');
      // Tambahkan timestamp untuk cache busting
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      print('Full API URL: $baseUrl/bookings?user_id=$userId&_t=$timestamp');
      final response = await http.get(
        Uri.parse('$baseUrl/bookings?user_id=$userId&_t=$timestamp'),
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Parsed data length: ${data.length}');
        print('Response type: ${data.runtimeType}');
        
        if (data.isEmpty) {
          print('WARNING: No booking data received from API');
        }
        
        final bookings = data.map((e) {
          print('=== BOOKING DATA ===');
          print('Raw booking: $e');
          print('ID: ${e['id']}');
          print('Status field: ${e['status']}');
          print('Status booking field: ${e['status_booking']}');
          print('Status pembayaran field: ${e['status_pembayaran']}');
          print('All fields: ${e.keys.toList()}');
          
          // Test: Cek semua field yang mungkin berisi status
          final possibleStatusFields = ['status', 'status_booking', 'booking_status', 'status_pembayaran', 'payment_status', 'state'];
          for (var field in possibleStatusFields) {
            if (e.containsKey(field)) {
              print('Found status in field "$field": ${e[field]}');
            }
          }
          print('==================');
          return Booking.fromJson(e);
        }).toList();
        
        print('Created ${bookings.length} booking objects');
        for (var booking in bookings) {
          print('Booking #${booking.id}: Status = ${booking.status}');
        }
        
        return bookings;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Gagal memuat riwayat booking: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchBookings: $e');
      throw Exception('Gagal memuat riwayat booking: $e');
    }
  }

  // Membuat booking baru
  static Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    print('Sending booking data: $bookingData'); // Debug print
    
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingData),
    );

    print('Response status: ${response.statusCode}'); // Debug print
    print('Response body: ${response.body}'); // Debug print

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Parsed response data: $data'); // Debug print
      
      // Coba berbagai format response yang mungkin
      Booking booking;
      int? extractedId;
      
      if (data is Map<String, dynamic>) {
        // Coba berbagai kemungkinan key untuk ID
        extractedId = data['id'] ?? data['booking_id'] ?? data['bookingId'];
        print('Extracted ID from response: $extractedId'); // Debug print
        
        if (extractedId != null) {
          booking = Booking.fromJson(data);
        } else {
          // Jika tidak ada ID, buat booking dengan ID dummy untuk sementara
          print('No ID found in response, creating booking with dummy ID'); // Debug print
          booking = Booking.fromJson(data);
          // Set ID dari data yang ada atau gunakan timestamp sebagai fallback
          extractedId = DateTime.now().millisecondsSinceEpoch;
        }
      } else if (data is List && data.isNotEmpty) {
        // Response adalah array
        final firstItem = data.first;
        if (firstItem is Map<String, dynamic>) {
          extractedId = firstItem['id'] ?? firstItem['booking_id'] ?? firstItem['bookingId'];
          booking = Booking.fromJson(Map<String, dynamic>.from(firstItem));
        } else {
          throw Exception('Format response tidak valid');
        }
      } else {
        print('Unknown response format: $data'); // Debug print
        throw Exception('Format response booking tidak dikenali: $data');
      }
      
      // Pastikan booking ID ada
      if (booking.id == null && extractedId != null) {
        print('Setting booking ID to: $extractedId'); // Debug print
        booking = Booking(
          id: extractedId,
          userId: booking.userId,
          homestayId: booking.homestayId,
          checkIn: booking.checkIn,
          checkOut: booking.checkOut,
          jumlahKamar: booking.jumlahKamar,
          totalHari: booking.totalHari,
          keterlambatan: booking.keterlambatan,
          denda: booking.denda,
          totalHarga: booking.totalHarga,
          catatan: booking.catatan,
          status: booking.status,
        );
      }
      
      print('Final booking ID: ${booking.id}'); // Debug print
      return booking;
    } else {
      print('Error response: ${response.body}'); // Debug print
      throw Exception('Gagal membuat booking: ${response.body}');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Email atau password salah');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal register: ${response.body}');
    }
  }

  static Future<Payment> createPayment({
    required int bookingId,
    required String metodePembayaran,
    required DateTime tanggalPembayaran,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'booking_id': bookingId,
        'metode_pembayaran': metodePembayaran,
        'tanggal_pembayaran': tanggalPembayaran.toIso8601String(),
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data));
    } else {
      throw Exception('Gagal konfirmasi pembayaran: ${response.body}');
    }
  }
}
