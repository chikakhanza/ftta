import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/homestay_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  final Homestay? homestay;

  const BookingDetailScreen({Key? key, required this.booking, this.homestay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Berhasil!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (homestay != null) ...[
              Text('Homestay: ${homestay!.nama}'),
              Text('Tipe Kamar: ${homestay!.tipeKamar}'),
              Text('Harga per Hari: Rp ${homestay!.harga.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
            ],
            Text('Tanggal Check-in: ${booking.checkIn.toLocal()}'),
            Text('Tanggal Check-out: ${booking.checkOut.toLocal()}'),
            Text('Jumlah Kamar: ${booking.jumlahKamar}'),
            Text('Total Harga: Rp ${booking.totalHarga}'),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
