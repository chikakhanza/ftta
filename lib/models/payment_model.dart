import 'booking_model.dart';

class Payment {
  final int? id;
  final int bookingId;
  final String metodePembayaran;
  final DateTime tanggalPembayaran;
  final double jumlahDibayar;
  final Booking? booking;

  Payment({
    this.id,
    required this.bookingId,
    required this.metodePembayaran,
    required this.tanggalPembayaran,
    required this.jumlahDibayar,
    this.booking,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['booking_id'],
      metodePembayaran: json['metode_pembayaran'],
      tanggalPembayaran: DateTime.parse(json['tanggal_pembayaran']),
      jumlahDibayar: (json['jumlah_dibayar'] as num).toDouble(),
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'metode_pembayaran': metodePembayaran,
      'tanggal_pembayaran': tanggalPembayaran.toIso8601String(),
      'jumlah_dibayar': jumlahDibayar,
    };
  }

  Payment copyWith({
    int? id,
    int? bookingId,
    String? metodePembayaran,
    DateTime? tanggalPembayaran,
    double? jumlahDibayar,
    Booking? booking,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      tanggalPembayaran: tanggalPembayaran ?? this.tanggalPembayaran,
      jumlahDibayar: jumlahDibayar ?? this.jumlahDibayar,
      booking: booking ?? this.booking,
    );
  }
} 