import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/homestay_model.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class BookingForm extends StatefulWidget {
  final Homestay homestay;
  final String? initialTipeKamar;

  const BookingForm({super.key, required this.homestay, this.initialTipeKamar});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahKamarController = TextEditingController(text: '1');
  final _catatanController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? _selectedTipeKamar;
  List<String> _selectedFasilitas = [];
  bool _isLoading = false;

  final List<String> _tipeKamarOptions = [
    'Standard',
    'Deluxe',
    'Suite',
  ];

  final Map<String, int> _hargaPerTipe = {
    'Standard': 500000,
    'Deluxe': 1000000,
    'Suite': 1500000,
  };

  final List<String> _fasilitasOptions = [
    'Laundry',
    'Sarapan',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTipeKamar = widget.initialTipeKamar ?? _tipeKamarOptions.first;
  }

  @override
  void dispose() {
    _jumlahKamarController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? DateTime.now() : (_checkInDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: isCheckIn ? DateTime.now() : (_checkInDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Reset check-out jika sebelum check-in
          if (_checkOutDate == null || _checkOutDate!.isBefore(picked)) {
            _checkOutDate = picked.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  int _calculateTotalHari() {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  int _calculateTotalBayar() {
    final totalHari = _calculateTotalHari();
    final jumlahKamar = int.tryParse(_jumlahKamarController.text) ?? 1;
    final harga = _hargaPerTipe[_selectedTipeKamar] ?? 0;
    int fasilitasCost = _selectedFasilitas.length * 50000;
    return harga * jumlahKamar * totalHari + fasilitasCost;
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
    if (_checkOutDate!.isBefore(_checkInDate!) || _checkOutDate!.isAtSameMomentAs(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal check-out harus setelah check-in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final totalBayar = _calculateTotalBayar();
    if (totalBayar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi data booking dengan benar!')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1;
      final totalHari = _calculateTotalHari();
      final jumlahKamar = int.parse(_jumlahKamarController.text);
      final bookingData = {
        'user_id': userId,
        'homestay_id': widget.homestay.id,
        'check_in': _checkInDate!.toIso8601String(),
        'check_out': _checkOutDate!.toIso8601String(),
        'jumlah_kamar': jumlahKamar,
        'total_hari': totalHari,
        'total_bayar': totalBayar,
        'catatan': _catatanController.text.trim(),
        'tipe_kamar': _selectedTipeKamar,
        'fasilitas_tambahan': _selectedFasilitas.join(', '),
        'tanggal_booking': DateTime.now().toIso8601String(),
      };
      final booking = await ApiService.createBooking(bookingData);
      if (booking.id == null) {
        throw Exception('Booking gagal dibuat - ID tidak ditemukan');
      }
      await prefs.setInt('last_booking_id', booking.id!);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              totalHarga: booking.totalHarga,
              bookingId: booking.id,
            ),
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
    final totalHari = _calculateTotalHari();
    final totalBayar = _calculateTotalBayar();
    final stokKamar = widget.homestay.jumlahKamar ?? 1;
    final hargaPerMalam = _hargaPerTipe[_selectedTipeKamar] ?? 0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8EAF1),
      appBar: AppBar(
        title: const Text('Form Booking'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Homestay
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.homestay.kode,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lokasi akan segera tersedia',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tipe Kamar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
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
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bed, color: Color(0xFFE91E63)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Pilih Tipe Kamar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTipeKamar,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE91E63)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                                              items: _tipeKamarOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTipeKamar = newValue;
                          _jumlahKamarController.text = '1';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jumlahKamarController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Kamar (Stok: $stokKamar)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE91E63)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        suffixIcon: Icon(
                          Icons.bed,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah kamar harus diisi';
                        }
                        final jumlah = int.tryParse(value);
                        if (jumlah == null || jumlah <= 0) {
                          return 'Jumlah kamar harus lebih dari 0';
                        }
                        if (jumlah > stokKamar) {
                          return 'Jumlah kamar melebihi stok tersedia ($stokKamar)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tanggal Menginap
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
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
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calendar_today, color: Color(0xFFE91E63)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tanggal Menginap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _checkInDate != null 
                                      ? const Color(0xFFE91E63) 
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _checkInDate != null 
                                    ? const Color(0xFFE91E63).withOpacity(0.05)
                                    : Colors.grey.shade50,
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.login, color: Color(0xFFE91E63)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _checkInDate != null
                                        ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
                                        : 'Check-in',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _checkInDate != null 
                                          ? const Color(0xFFE91E63)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _checkOutDate != null 
                                      ? const Color(0xFFE91E63) 
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _checkOutDate != null 
                                    ? const Color(0xFFE91E63).withOpacity(0.05)
                                    : Colors.grey.shade50,
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.logout, color: Color(0xFFE91E63)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _checkOutDate != null
                                        ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
                                        : 'Check-out',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _checkOutDate != null 
                                          ? const Color(0xFFE91E63)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFFE91E63)),
                          const SizedBox(width: 8),
                          const Text('Total Hari: '),
                          Text(
                            '$totalHari hari',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fasilitas Tambahan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
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
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_circle_outline, color: Color(0xFFE91E63)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Fasilitas Tambahan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _fasilitasOptions.map((String fasilitas) {
                        final isSelected = _selectedFasilitas.contains(fasilitas);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedFasilitas.remove(fasilitas);
                              } else {
                                _selectedFasilitas.add(fasilitas);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFFE91E63) 
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFFE91E63) 
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  fasilitas == 'Laundry' ? Icons.local_laundry_service : Icons.restaurant,
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  fasilitas,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Total Pembayaran
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
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
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.payment, color: Colors.green),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Harga per malam:'),
                        Text(
                          'Rp ${hargaPerMalam.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jumlah kamar:'),
                        Text(
                          '${_jumlahKamarController.text} kamar',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total hari:'),
                        Text(
                          '$totalHari hari',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    if (_selectedFasilitas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fasilitas tambahan:'),
                          Text(
                            'Rp ${(_selectedFasilitas.length * 50000).toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Bayar:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${totalBayar.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Catatan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
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
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.note, color: Color(0xFFE91E63)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Catatan (Opsional)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _catatanController,
                      decoration: InputDecoration(
                        labelText: 'Catatan untuk pemilik homestay',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE91E63)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Lanjutkan ke Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}