import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Booking> _riwayatBooking = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBookingHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali screen menjadi aktif
    print('BookingHistoryScreen: didChangeDependencies called');
    _loadBookingHistory();
  }



  Future<void> _loadBookingHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1; // Default to 1 if not set
      
      print('Loading booking history for user ID: $userId');
      print('User ID from SharedPreferences: ${prefs.getInt('user_id')}');
      print('Using user ID: $userId');
      
      final bookings = await ApiService.fetchBookings(userId);
      print('Loaded ${bookings.length} bookings from API');
      
      // Debug: print status of each booking
      for (var booking in bookings) {
        print('Booking #${booking.id}: Status = ${booking.status}');
        print('  - Check-in: ${booking.checkIn}');
        print('  - Check-out: ${booking.checkOut}');
        print('  - Total: Rp${booking.totalHarga}');
      }
      
      setState(() {
        _riwayatBooking = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading booking history: $e');
      setState(() {
        _error = 'Gagal memuat riwayat booking: $e';
        _isLoading = false;
      });
    }
  }



  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Colors.green;
      case 'selesai':
        return Colors.blue;
      case 'dibatalkan':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Icons.check_circle;
      case 'selesai':
        return Icons.done_all;
      case 'dibatalkan':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              print('Manual refresh triggered');
              _loadBookingHistory();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667EEA),
                strokeWidth: 3,
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Oops! Terjadi kesalahan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : _riwayatBooking.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada riwayat booking',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Booking homestay untuk melihat\nriwayat di sini',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookingHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _riwayatBooking.length,
                        itemBuilder: (context, index) {
                                                  final booking = _riwayatBooking[index];
                        print('Building card for booking #${booking.id} with status: ${booking.status}');
                        
                        // Test: Force status untuk debugging
                        String displayStatus = booking.status ?? 'Pending';
                        if (booking.id == 22 || booking.id == 23) {
                          displayStatus = 'Diterima'; // Force untuk test
                          print('Forcing status to "Diterima" for booking #${booking.id}');
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _buildBookingCard(booking, displayStatus),
                        );
                        },
                      ),
                    ),
    );
  }

  Widget _buildBookingCard(Booking booking, [String? customStatus]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header dengan status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(customStatus ?? booking.status ?? 'pending').withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(customStatus ?? booking.status ?? 'pending'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(customStatus ?? booking.status ?? 'pending'),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #${booking.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Homestay ID: ${booking.homestayId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(customStatus ?? booking.status ?? 'pending'),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    customStatus ?? booking.status ?? 'Pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Tanggal Check-in/Check-out
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.login,
                        title: 'Check-in',
                        value: booking.checkIn.toLocal().toString().split(" ")[0],
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.logout,
                        title: 'Check-out',
                        value: booking.checkOut.toLocal().toString().split(" ")[0],
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Informasi Kamar dan Durasi
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.bed,
                        title: 'Jumlah Kamar',
                        value: '${booking.jumlahKamar} kamar',
                        color: const Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.calendar_today,
                        title: 'Total Hari',
                        value: '${booking.totalHari} hari',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Catatan
                if (booking.catatan != null && booking.catatan!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Catatan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.catatan!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (booking.catatan != null && booking.catatan!.isNotEmpty)
                  const SizedBox(height: 16),
                
                // Total Harga
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${booking.totalHarga.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}
