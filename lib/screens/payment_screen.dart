import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;
  final int totalHarga;

  const PaymentScreen({super.key, required this.booking, required this.totalHarga});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isPaying = false;

  Future<void> _handlePayment(BuildContext context) async {
    setState(() => _isPaying = true);
    final success = await ApiService.payBooking(widget.booking.homestayId); // Ganti dengan booking.id jika ada
    setState(() => _isPaying = false);
    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pembayaran Berhasil'),
          content: const Text('Terima kasih, pembayaran Anda telah diterima.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran gagal'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Silakan pilih metode pembayaran:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Transfer Bank'),
              onTap: _isPaying ? null : () => _handlePayment(context),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QRIS'),
              onTap: _isPaying ? null : () => _handlePayment(context),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Total Bayar: Rp ${widget.totalHarga}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (_isPaying)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
