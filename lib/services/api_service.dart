import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/homestay_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';


class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // Adjust to your Laravel backend URL

  // User APIs
  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<User> createUser(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Login failed');
    }
  }

  // Homestay APIs
  static Future<List<Homestay>> getHomestays() async {
    final response = await http.get(Uri.parse('$baseUrl/homestays'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Homestay.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load homestays');
    }
  }

  static Future<Homestay> getHomestay(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/homestays/$id'));
    if (response.statusCode == 200) {
      return Homestay.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load homestay');
    }
  }

  // Booking APIs
  static Future<List<Booking>> getBookings() async {
    final response = await http.get(Uri.parse('$baseUrl/bookings'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  static Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bookingData),
    );
    if (response.statusCode == 201) {
      return Booking.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create booking');
    }
  }

  static Future<Booking> getBooking(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings/$id'));
    if (response.statusCode == 200) {
      return Booking.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load booking');
    }
  }

  // Payment APIs
  static Future<List<Payment>> getPayments() async {
    final response = await http.get(Uri.parse('$baseUrl/payments'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  static Future<Payment> createPayment(Map<String, dynamic> paymentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(paymentData),
    );
    if (response.statusCode == 201) {
      return Payment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create payment');
    }
  }

  static Future<Payment> getPayment(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/payments/$id'));
    if (response.statusCode == 200) {
      return Payment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load payment');
    }
  }
} 