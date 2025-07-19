import 'user_model.dart';
import 'homestay_model.dart';

class Booking {
  final int? id;
  final int userId;
  final int homestayId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int jumlahKamar;
  final int totalHari;
  final int keterlambatan;
  final double denda;
  final double totalBayar;
  final String? catatan;
  final User? user;
  final Homestay? homestay;

  Booking({
    this.id,
    required this.userId,
    required this.homestayId,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahKamar,
    required this.totalHari,
    this.keterlambatan = 0,
    this.denda = 0,
    required this.totalBayar,
    this.catatan,
    this.user,
    this.homestay,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      homestayId: json['homestay_id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      jumlahKamar: json['jumlah_kamar'],
      totalHari: json['total_hari'],
      keterlambatan: json['keterlambatan'] ?? 0,
      denda: (json['denda'] as num?)?.toDouble() ?? 0,
      totalBayar: (json['total_bayar'] as num).toDouble(),
      catatan: json['catatan'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      homestay: json['homestay'] != null ? Homestay.fromJson(json['homestay']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'homestay_id': homestayId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'jumlah_kamar': jumlahKamar,
      'total_hari': totalHari,
      'keterlambatan': keterlambatan,
      'denda': denda,
      'total_bayar': totalBayar,
      'catatan': catatan,
    };
  }

  Booking copyWith({
    int? id,
    int? userId,
    int? homestayId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? jumlahKamar,
    int? totalHari,
    int? keterlambatan,
    double? denda,
    double? totalBayar,
    String? catatan,
    User? user,
    Homestay? homestay,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      homestayId: homestayId ?? this.homestayId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      jumlahKamar: jumlahKamar ?? this.jumlahKamar,
      totalHari: totalHari ?? this.totalHari,
      keterlambatan: keterlambatan ?? this.keterlambatan,
      denda: denda ?? this.denda,
      totalBayar: totalBayar ?? this.totalBayar,
      catatan: catatan ?? this.catatan,
      user: user ?? this.user,
      homestay: homestay ?? this.homestay,
    );
  }
} 