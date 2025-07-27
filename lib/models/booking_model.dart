class Booking {
  final int userId;
  final int homestayId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int jumlahKamar;
  final int totalHarga;

  Booking({
    required this.userId,
    required this.homestayId,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahKamar,
    required this.totalHarga,
  });
}
