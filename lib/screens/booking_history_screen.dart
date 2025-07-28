import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingHistoryScreen extends StatelessWidget {
  final List<Booking> riwayatBooking;

  const BookingHistoryScreen({super.key, required this.riwayatBooking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
      ),
      body: ListView.builder(
        itemCount: riwayatBooking.length,
        itemBuilder: (context, index) {
          final booking = riwayatBooking[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Homestay ID: ${booking.homestayId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check-in: ${booking.checkIn.toLocal().toString().split(" ")[0]}'),
                  Text('Check-out: ${booking.checkOut.toLocal().toString().split(" ")[0]}'),
                  Text('Jumlah Kamar: ${booking.jumlahKamar}'),
                  Text('Total Harga: Rp${booking.totalHarga}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
