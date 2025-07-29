import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EAF1),
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Booking
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(booking.status),
                          color: _getStatusColor(booking.status),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Booking',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                booking.status ?? 'Pending',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(booking.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Booking
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('ID Booking', '#${booking.id}'),
                    _buildInfoRow('Tanggal Booking', 
                        booking.tanggalBooking != null 
                            ? '${booking.tanggalBooking!.day}/${booking.tanggalBooking!.month}/${booking.tanggalBooking!.year}'
                            : 'Tidak tersedia'),
                    _buildInfoRow('Tipe Kamar', booking.tipeKamar ?? 'Standard'),
                    _buildInfoRow('Jumlah Kamar', '${booking.jumlahKamar} kamar'),
                    _buildInfoRow('Jumlah Dewasa', '${booking.jumlahDewasa} orang'),
                    _buildInfoRow('Jumlah Anak', '${booking.jumlahAnak} orang'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tanggal Menginap
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Menginap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Check-in', 
                        '${booking.checkIn.day}/${booking.checkIn.month}/${booking.checkIn.year}'),
                    _buildInfoRow('Check-out', 
                        '${booking.checkOut.day}/${booking.checkOut.month}/${booking.checkOut.year}'),
                    _buildInfoRow('Total Hari', '${booking.totalHari} hari'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fasilitas Tambahan
            if (booking.fasilitasTambahan != null && booking.fasilitasTambahan!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fasilitas Tambahan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: booking.fasilitasTambahan!.split(',').map((fasilitas) {
                          return Chip(
                            label: Text(fasilitas.trim()),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Informasi Pembayaran
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Total Bayar', 'Rp ${booking.totalHarga.toStringAsFixed(0)}'),
                    if (booking.keterlambatan > 0) ...[
                      _buildInfoRow('Keterlambatan', '${booking.keterlambatan} hari'),
                      _buildInfoRow('Denda', 'Rp ${booking.denda.toStringAsFixed(0)}'),
                    ],
                    if (booking.metodePembayaran != null) ...[
                      _buildInfoRow('Metode Pembayaran', booking.metodePembayaran!),
                    ],
                    if (booking.statusPembayaran != null) ...[
                      _buildInfoRow('Status Pembayaran', booking.statusPembayaran!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Catatan
            if (booking.catatan != null && booking.catatan!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Khusus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        booking.catatan!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'dikonfirmasi':
        return Icons.check_circle;
      case 'pending':
      case 'menunggu':
        return Icons.schedule;
      case 'cancelled':
      case 'dibatalkan':
        return Icons.cancel;
      case 'completed':
      case 'selesai':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'dikonfirmasi':
        return Colors.green;
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      case 'cancelled':
      case 'dibatalkan':
        return Colors.red;
      case 'completed':
      case 'selesai':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
