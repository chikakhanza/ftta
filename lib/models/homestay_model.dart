class Homestay {
  final int? id;
  final String kode;
  final String tipeKamar;
  final double hargaSewaPerHari;
  final String? fasilitas;
  final int jumlahKamar;
  final int lamaInap;
  final double totalBayar;

  Homestay({
    this.id,
    required this.kode,
    required this.tipeKamar,
    required this.hargaSewaPerHari,
    this.fasilitas,
    required this.jumlahKamar,
    required this.lamaInap,
    required this.totalBayar,
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    return Homestay(
      id: json['id'],
      kode: json['kode'],
      tipeKamar: json['tipe_kamar'],
      hargaSewaPerHari: (json['harga_sewa_per_hari'] as num).toDouble(),
      fasilitas: json['fasilitas'],
      jumlahKamar: json['jumlah_kamar'],
      lamaInap: json['lama_inap'],
      totalBayar: (json['total_bayar'] as num).toDouble(),
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
      'lama_inap': lamaInap,
      'total_bayar': totalBayar,
    };
  }

  Homestay copyWith({
    int? id,
    String? kode,
    String? tipeKamar,
    double? hargaSewaPerHari,
    String? fasilitas,
    int? jumlahKamar,
    int? lamaInap,
    double? totalBayar,
  }) {
    return Homestay(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      tipeKamar: tipeKamar ?? this.tipeKamar,
      hargaSewaPerHari: hargaSewaPerHari ?? this.hargaSewaPerHari,
      fasilitas: fasilitas ?? this.fasilitas,
      jumlahKamar: jumlahKamar ?? this.jumlahKamar,
      lamaInap: lamaInap ?? this.lamaInap,
      totalBayar: totalBayar ?? this.totalBayar,
    );
  }
} 