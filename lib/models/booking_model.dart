class Booking {
  final int userId;
  final int homestayId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int jumlahKamar;
  final int totalHarga;
  final String status;

  Booking({
    required this.userId,
    required this.homestayId,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahKamar,
    required this.totalHarga,
    this.status = 'pending',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      userId: json['user_id'],
      homestayId: json['homestay_id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      jumlahKamar: json['jumlah_kamar'],
      totalHarga: json['total_harga'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'homestay_id': homestayId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'jumlah_kamar': jumlahKamar,
      'total_harga': totalHarga,
      'status': status,
    };
  }
}
