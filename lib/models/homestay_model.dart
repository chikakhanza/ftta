class Homestay {
  final int id;
  final String kode;
  final String tipeKamar;
  final int hargaSewaPerHari;
  final String? fasilitas;
  final int jumlahKamar;
  final String? fotokamar;
  final String? createdAt;
  final String? updatedAt;

  Homestay({
    required this.id,
    required this.kode,
    required this.tipeKamar,
    required this.hargaSewaPerHari,
    this.fasilitas,
    required this.jumlahKamar,
    this.fotokamar,
    this.createdAt,
    this.updatedAt,
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    return Homestay(
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      tipeKamar: json['tipe_kamar'] ?? '',
      hargaSewaPerHari: json['harga_sewa_per_hari'] ?? 0,
      fasilitas: json['fasilitas'],
      jumlahKamar: json['jumlah_kamar'] ?? 0,
      fotokamar: json['fotokamar'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'tipe_kamar': tipeKamar,
      'harga_sewa_per_hari': hargaSewaPerHari,
      'fasilitas': fasilitas,
      'jumlah_kamar': jumlahKamar,
      'fotokamar': fotokamar,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method untuk mendapatkan URL foto lengkap
  String? getImageUrl() {
    if (fotokamar != null && fotokamar!.isNotEmpty) {
      return 'http://192.168.1.38:8000/fotokamar/$fotokamar';
    }
    return null;
  }

  // Helper method untuk debugging URL
  String getDebugInfo() {
    return 'Homestay ${kode}: fotokamar=${fotokamar}, URL=${getImageUrl()}';
  }
} 
//membuat homestay
