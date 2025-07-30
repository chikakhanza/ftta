import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  final List<Booking> riwayatBooking;

  const BookingHistoryScreen({super.key, required this.riwayatBooking});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late List<Booking> _riwayatBooking;

  @override
  void initState() {
    super.initState();
    _riwayatBooking = List.from(widget.riwayatBooking);
  }

  Future<void> _cancelBooking(int index) async {
    final booking = _riwayatBooking[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin membatalkan booking ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await ApiService.cancelBooking(booking.homestayId); // Ganti dengan bookingId jika ada
    if (success) {
      setState(() {
        _riwayatBooking[index] = Booking(
          userId: booking.userId,
          homestayId: booking.homestayId,
          checkIn: booking.checkIn,
          checkOut: booking.checkOut,
          jumlahKamar: booking.jumlahKamar,
          totalHarga: booking.totalHarga,
          status: 'cancelled',
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking berhasil dibatalkan'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membatalkan booking'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
      ),
      body: ListView.builder(
        itemCount: _riwayatBooking.length,
        itemBuilder: (context, index) {
          final booking = _riwayatBooking[index];
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
                  Row(
                    children: [
                      Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: booking.status == 'pending' ? Colors.orange : booking.status == 'paid' ? Colors.green : booking.status == 'cancelled' ? Colors.red : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (booking.status == 'pending')
                        TextButton(
                          onPressed: () => _cancelBooking(index),
                          child: const Text('Batalkan', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
