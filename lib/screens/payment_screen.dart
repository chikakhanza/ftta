import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'transfer';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'qris', 'label': 'QRIS', 'icon': Icons.qr_code},
    {'value': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'value': 'tunai', 'label': 'Tunai', 'icon': Icons.money},
  ];

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentData = {
        'booking_id': widget.booking.id,
        'metode_pembayaran': _selectedPaymentMethod,
        'tanggal_pembayaran': DateTime.now().toIso8601String(),
      };

      await ApiService.createPayment(paymentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses pembayaran: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Booking',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Check-in', '${widget.booking.checkIn.day}/${widget.booking.checkIn.month}/${widget.booking.checkIn.year}'),
                    _buildInfoRow('Check-out', '${widget.booking.checkOut.day}/${widget.booking.checkOut.month}/${widget.booking.checkOut.year}'),
                    _buildInfoRow('Total Hari', '${widget.booking.totalHari} hari'),
                    _buildInfoRow('Jumlah Kamar', '${widget.booking.jumlahKamar} kamar'),
                    if (widget.booking.keterlambatan > 0) ...[
                      _buildInfoRow('Keterlambatan', '${widget.booking.keterlambatan} hari'),
                      _buildInfoRow('Denda', 'Rp ${widget.booking.denda.toStringAsFixed(0)}'),
                    ],
                    const Divider(),
                    _buildInfoRow(
                      'Total Bayar',
                      'Rp ${widget.booking.totalBayar.toStringAsFixed(0)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...(_paymentMethods.map((method) => RadioListTile<String>(
                      value: method['value'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      title: Row(
                        children: [
                          Icon(method['icon']),
                          const SizedBox(width: 8),
                          Text(method['label']),
                        ],
                      ),
                      activeColor: Theme.of(context).primaryColor,
                    ))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Bayar Sekarang',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green[600] : null,
            ),
          ),
        ],
      ),
    );
  }
} 