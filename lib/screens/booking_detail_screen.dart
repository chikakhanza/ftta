import 'package:flutter/material.dart';
import '../models/homestay_model.dart';
import '../models/booking_model.dart';
import '../screens/payment_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final Homestay homestay;

  const BookingFormScreen({super.key, required this.homestay});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTimeRange? _tanggal;
  int _jumlahKamar = 1;

  void _submitBooking() {
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal terlebih dahulu.')),
      );
      return;
    }

    final totalHari = _tanggal!.end.difference(_tanggal!.start).inDays;
    final totalHarga = totalHari * _jumlahKamar * widget.homestay.harga;

    final booking = Booking(
      userId: 1,
      homestayId: widget.homestay.id,
      checkIn: _tanggal!.start,
      checkOut: _tanggal!.end,
      jumlahKamar: _jumlahKamar,
      totalHari: totalHari,
      denda: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          booking: booking,
          homestay: widget.homestay,
          totalHarga: totalHarga,
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.homestay.nama, style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Pilih Tanggal'),
              subtitle: Text(_tanggal == null
                  ? 'Belum dipilih'
                  : '${_tanggal!.start.toLocal()} - ${_tanggal!.end.toLocal()}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDateRange,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Jumlah Kamar:'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _jumlahKamar = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Lanjut ke Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
