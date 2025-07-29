class Booking {
  final int? id;
  final int userId;
  final int homestayId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int jumlahKamar;
  final int totalHari;
  final int keterlambatan;
  final int denda;
  final int totalHarga;
  final String? catatan;
  final String? status;
  final int jumlahDewasa;
  final int jumlahAnak;
  final String? tipeKamar;
  final String? fasilitasTambahan;
  final DateTime? tanggalBooking;
  final String? metodePembayaran;
  final String? statusPembayaran;

  Booking({
    this.id,
    required this.userId,
    required this.homestayId,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahKamar,
    required this.totalHari,
    required this.keterlambatan,
    required this.denda,
    required this.totalHarga,
    this.catatan,
    this.status,
    this.jumlahDewasa = 1,
    this.jumlahAnak = 0,
    this.tipeKamar,
    this.fasilitasTambahan,
    this.tanggalBooking,
    this.metodePembayaran,
    this.statusPembayaran,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    print('Booking.fromJson - Raw data: $json');
    print('Booking.fromJson - Status field: ${json['status']}');
    print('Booking.fromJson - Status booking field: ${json['status_booking']}');
    print('Booking.fromJson - Booking status field: ${json['booking_status']}');
    print('Booking.fromJson - Status pembayaran field: ${json['status_pembayaran']}');
    
    return Booking(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      homestayId: json['homestay_id'] ?? 0,
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      jumlahKamar: json['jumlah_kamar'] ?? 1,
      totalHari: json['total_hari'] ?? 0,
      keterlambatan: json['keterlambatan'] ?? 0,
      denda: json['denda'] ?? 0,
      totalHarga: json['total_bayar'] ?? json['totalHarga'] ?? 0,
      catatan: json['catatan'],
      status: _parseStatus(_findStatusField(json)),
      jumlahDewasa: json['jumlah_dewasa'] ?? 1,
      jumlahAnak: json['jumlah_anak'] ?? 0,
      tipeKamar: json['tipe_kamar'],
      fasilitasTambahan: json['fasilitas_tambahan'],
      tanggalBooking: json['tanggal_booking'] != null 
          ? DateTime.parse(json['tanggal_booking']) 
          : null,
      metodePembayaran: json['metode_pembayaran'],
      statusPembayaran: json['status_pembayaran'],
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
      'total_bayar': totalHarga,
      'catatan': catatan,
      'status': status,
      'jumlah_dewasa': jumlahDewasa,
      'jumlah_anak': jumlahAnak,
      'tipe_kamar': tipeKamar,
      'fasilitas_tambahan': fasilitasTambahan,
      'tanggal_booking': tanggalBooking?.toIso8601String(),
      'metode_pembayaran': metodePembayaran,
      'status_pembayaran': statusPembayaran,
    };
  }

  // Helper method untuk mencari field status
  static dynamic _findStatusField(Map<String, dynamic> json) {
    final possibleFields = [
      'status',
      'status_booking', 
      'booking_status',
      'status_pembayaran',
      'payment_status',
      'state',
      'booking_state'
    ];
    
    for (var field in possibleFields) {
      if (json.containsKey(field) && json[field] != null) {
        print('Found status in field "$field": ${json[field]}');
        return json[field];
      }
    }
    
    print('No status field found, defaulting to "pending"');
    return 'pending';
  }

  // Helper method untuk parse status dari berbagai format
  static String _parseStatus(dynamic status) {
    if (status == null) return 'pending';
    
    String statusStr = status.toString().toLowerCase();
    print('Parsing status: "$status" -> "$statusStr"');
    
    // Mapping berbagai kemungkinan status
    switch (statusStr) {
      case 'diterima':
      case 'received':
      case 'selesai':
      case 'completed':
      case 'success':
        return 'Diterima';
      case 'pending':
      case 'menunggu':
      case 'waiting':
        return 'Pending';
      case 'dibatalkan':
      case 'cancelled':
      case 'canceled':
        return 'Dibatalkan';
      case 'aktif':
      case 'active':
        return 'Aktif';
      default:
        print('Unknown status: "$statusStr", defaulting to "Pending"');
        return 'Pending';
    }
  }
}
