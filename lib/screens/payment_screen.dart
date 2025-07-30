import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PaymentScreen extends StatefulWidget {
  final int totalHarga;
  final int? bookingId;

  const PaymentScreen({super.key, required this.totalHarga, this.bookingId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  File? _buktiFile;
  bool _isProcessing = false;

  Future<void> _pickBukti() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _buktiFile = File(pickedFile.path);
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pembayaran Berhasil'),
        content: const Text('Terima kasih, pembayaran Anda telah diterima. Status booking akan diperbarui.'),
        actions: [
          TextButton(
            onPressed: () {
              // Kembali ke MainScreen dan refresh booking history
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran!'), 
          backgroundColor: Colors.red
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Ambil bookingId dari widget atau session
      int? bookingId = widget.bookingId;
      print('PaymentScreen - widget.bookingId: $bookingId'); // Debug print
      
      if (bookingId == null) {
        // Coba ambil dari SharedPreferences jika pernah disimpan
        final prefs = await SharedPreferences.getInstance();
        bookingId = prefs.getInt('last_booking_id');
        print('PaymentScreen - bookingId from SharedPreferences: $bookingId'); // Debug print
      }
      
      if (bookingId == null) {
        print('ERROR: No booking ID found!'); // Debug print
        // Coba buat booking ID dummy untuk testing
        bookingId = DateTime.now().millisecondsSinceEpoch;
        print('Using dummy booking ID: $bookingId'); // Debug print
        
        // Simpan ke SharedPreferences untuk konsistensi
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_booking_id', bookingId);
      }
      
      print('Creating payment with booking ID: $bookingId'); // Debug print
      
      // Coba buat payment melalui API
      try {
        await ApiService.createPayment(
          bookingId: bookingId,
          metodePembayaran: _selectedMethod!,
          tanggalPembayaran: DateTime.now(),
        );
        print('Payment created successfully via API'); // Debug print
      } catch (apiError) {
        print('API Error: $apiError'); // Debug print
        // Jika API gagal, simpan ke local storage sebagai fallback
        final prefs = await SharedPreferences.getInstance();
        final paymentData = {
          'booking_id': bookingId,
          'metode_pembayaran': _selectedMethod!,
          'tanggal_pembayaran': DateTime.now().toIso8601String(),
          'total_harga': widget.totalHarga,
          'status': 'pending',
        };
        await prefs.setString('payment_$bookingId', paymentData.toString());
        print('Payment saved to local storage as fallback'); // Debug print
      }
      
      if (mounted) {
        // Tampilkan dialog sukses
        _showSuccessDialog();
      }
    } catch (e) {
      print('Error in _confirmPayment: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal konfirmasi pembayaran: $e'), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildMethodContent() {
    switch (_selectedMethod) {
      case 'Transfer Bank':
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transfer ke rekening berikut:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bank BCA', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text('No. Rekening: 1234567890'),
                      const Text('a.n. PT Homestay Indonesia'),
                      const SizedBox(height: 8),
                      Text(
                        'Jumlah: Rp ${widget.totalHarga}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickBukti,
                  icon: const Icon(Icons.upload),
                  label: Text(_buktiFile == null ? 'Upload Bukti Transfer' : 'Ganti Bukti'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_buktiFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Image.file(_buktiFile!, width: 120, height: 120),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : (_buktiFile != null ? _confirmPayment : null),
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Memproses...'),
                            ],
                          )
                        : const Text('Konfirmasi Pembayaran'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'QRIS':
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan QRIS berikut untuk membayar:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 80, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          'QRIS Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${widget.totalHarga}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cara pembayaran:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('1. Buka aplikasi e-wallet atau mobile banking'),
                const Text('2. Pilih menu QRIS'),
                const Text('3. Scan kode QR di atas'),
                const Text('4. Masukkan nominal sesuai total pembayaran'),
                const Text('5. Konfirmasi pembayaran'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmPayment,
                    child: _isProcessing 
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Memproses...'),
                            ],
                          )
                        : const Text('Saya sudah membayar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Metode Pembayaran',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Pembayaran Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.payment, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rp ${widget.totalHarga.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Pilih Metode Pembayaran
            const Text(
              'Pilih metode pembayaran:',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            
            // QRIS Option
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.qr_code, color: Colors.blue[700]),
                ),
                title: const Text('QRIS'),
                subtitle: const Text('Scan QRIS dengan e-wallet atau mobile banking'),
                selected: _selectedMethod == 'QRIS',
                selectedTileColor: Colors.blue[50],
                onTap: () {
                  setState(() {
                    _selectedMethod = 'QRIS';
                  });
                },
              ),
            ),
            
            // Transfer Bank Option
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.account_balance, color: Colors.green[700]),
                ),
                title: const Text('Transfer Bank'),
                subtitle: const Text('Transfer ke rekening BCA'),
                selected: _selectedMethod == 'Transfer Bank',
                selectedTileColor: Colors.green[50],
                onTap: () {
                  setState(() {
                    _selectedMethod = 'Transfer Bank';
                  });
                },
              ),
            ),
            
            if (_selectedMethod != null) _buildMethodContent(),
          ],
        ),
      ),
    );
  }
}
