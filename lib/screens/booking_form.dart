import 'package:flutter/material.dart';
import '../models/homestay_model.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final Homestay homestay;

  const BookingFormScreen({
    super.key,
    required this.homestay,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahKamarController = TextEditingController(text: '1');
  final _keterlambatanController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();
  
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _jumlahKamarController.dispose();
    _keterlambatanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  double _calculateTotalBayar() {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    
    final totalHari = _checkOutDate!.difference(_checkInDate!).inDays;
    final jumlahKamar = int.tryParse(_jumlahKamarController.text) ?? 1;
    final keterlambatan = int.tryParse(_keterlambatanController.text) ?? 0;
    
    double totalBayar = widget.homestay.hargaSewaPerHari * totalHari * jumlahKamar;
    
    // Hitung denda (10% per hari keterlambatan)
    if (keterlambatan > 0) {
      totalBayar += totalBayar * 0.1 * keterlambatan;
    }
    
    return totalBayar;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal check-in dan check-out'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final totalHari = _checkOutDate!.difference(_checkInDate!).inDays;
      final jumlahKamar = int.parse(_jumlahKamarController.text);
      final keterlambatan = int.parse(_keterlambatanController.text);
      final totalBayar = _calculateTotalBayar();
      final denda = keterlambatan > 0 ? totalBayar * 0.1 * keterlambatan : 0;

      final bookingData = {
        'user_id': 1, // TODO: Get from user session
        'homestay_id': widget.homestay.id,
        'check_in': _checkInDate!.toIso8601String(),
        'check_out': _checkOutDate!.toIso8601String(),
        'jumlah_kamar': jumlahKamar,
        'total_hari': totalHari,
        'keterlambatan': keterlambatan,
        'denda': denda,
        'total_bayar': totalBayar,
        'catatan': _catatanController.text.trim(),
      };

      final booking = await ApiService.createBooking(bookingData);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(booking: booking),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat booking: ${e.toString()}'),
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
    final totalBayar = _calculateTotalBayar();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Booking'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                        'Detail Homestay',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Kode: ${widget.homestay.kode}'),
                      Text('Tipe: ${widget.homestay.tipeKamar}'),
                      Text('Harga: Rp ${widget.homestay.hargaSewaPerHari.toStringAsFixed(0)}/hari'),
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
                        'Informasi Booking',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Check-in Date'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today),
                                        const SizedBox(width: 8),
                                        Text(
                                          _checkInDate == null
                                              ? 'Pilih tanggal'
                                              : '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Check-out Date'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today),
                                        const SizedBox(width: 8),
                                        Text(
                                          _checkOutDate == null
                                              ? 'Pilih tanggal'
                                              : '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jumlahKamarController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Kamar',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah kamar tidak boleh kosong';
                          }
                          final jumlah = int.tryParse(value);
                          if (jumlah == null || jumlah < 1) {
                            return 'Jumlah kamar minimal 1';
                          }
                          if (jumlah > widget.homestay.jumlahKamar) {
                            return 'Jumlah kamar melebihi ketersediaan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _keterlambatanController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Keterlambatan (hari)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Keterlambatan tidak boleh kosong';
                          }
                          final keterlambatan = int.tryParse(value);
                          if (keterlambatan == null || keterlambatan < 0) {
                            return 'Keterlambatan tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _catatanController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          border: OutlineInputBorder(),
                        ),
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
                        'Total Pembayaran',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${totalBayar.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
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
                          'Lanjut ke Pembayaran',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 