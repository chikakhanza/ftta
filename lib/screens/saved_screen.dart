import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/homestay_model.dart';
import '../services/api_service.dart';
import 'homestay_detail.dart';
import 'booking_form.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Homestay> _savedHomestays = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSavedHomestays();
  }

  Future<void> _loadSavedHomestays() async {
    try {
    setState(() {
      _isLoading = true;
        _error = '';
      });

      // Load favorite IDs from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorites') ?? [];
      
      if (favoriteIds.isEmpty) {
        setState(() {
          _savedHomestays = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch all homestays from API
      final allHomestays = await ApiService.fetchHomestays();
      
      // Filter homestays that are in favorites
      final savedHomestays = allHomestays.where((homestay) {
        return homestay.id != null && 
               favoriteIds.contains(homestay.id.toString());
      }).toList();
    
    setState(() {
        _savedHomestays = savedHomestays;
        _isLoading = false;
      });

      print('Loaded ${_savedHomestays.length} saved homestays from ${favoriteIds.length} favorite IDs');
    } catch (e) {
      print('Error loading saved homestays: $e');
      setState(() {
        _error = 'Gagal memuat homestay favorit: $e';
      _isLoading = false;
    });
    }
  }

  Future<void> _removeFromFavorites(int homestayId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites') ?? [];
      favorites.remove(homestayId.toString());
      await prefs.setStringList('favorites', favorites);
      
      // Remove from local list
      setState(() {
        _savedHomestays.removeWhere((homestay) => homestay.id == homestayId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Homestay dihapus dari favorit'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EAF1),
      appBar: AppBar(
        title: const Text('Simpan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedHomestays,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSavedHomestays,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _savedHomestays.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada homestay disimpan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simpan homestay favorit Anda untuk melihatnya nanti',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to Explore screen
                              Navigator.of(context).pushNamed('/explore');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Jelajahi Homestay'),
                          ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedHomestays.length,
                  itemBuilder: (context, index) {
                    final homestay = _savedHomestays[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                      onTap: () {
                              Navigator.push(
                                context,
                          MaterialPageRoute(
                            builder: (context) => HomestayDetailScreen(homestay: homestay),
                                ),
                              );
                            },
                            child: Container(
                              height: 200,
                              child: Row(
                                children: [
                                  // Image section
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.blue[300]!,
                                            Colors.blue[600]!,
                                          ],
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Background image
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                bottomLeft: Radius.circular(12),
                                              ),
                                              child: Image.asset(
                                                homestay.id! % 2 == 0 
                                                    ? 'assets/images/hm2.jpg'
                                                    : 'assets/images/hm1.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          // Overlay gradient
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  bottomLeft: Radius.circular(12),
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.3),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Room type indicator
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                homestay.tipeKamar.substring(0, 3),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF6A4C93),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Remove from favorites button
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (homestay.id != null) {
                                                  _removeFromFavorites(homestay.id!);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Content section
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Homestay code
                                          Text(
                                            homestay.kode,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6A4C93),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Price
                                          Row(
                                            children: [
                                              const Icon(Icons.attach_money, color: Colors.green, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Rp ${homestay.hargaSewaPerHari.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/malam',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Room info
                                          Row(
                                            children: [
                                              Icon(Icons.bed, color: Colors.grey[600], size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${homestay.jumlahKamar} kamar',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Facilities
                                          Text(
                                            'Fasilitas: ${homestay.fasilitas?.split(',').take(3).join(', ') ?? 'Tidak ada info'}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          // Book button
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => BookingForm(homestay: homestay),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).primaryColor,
                                                foregroundColor: Colors.white,
                                                minimumSize: const Size(80, 32),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                'Pesan',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                  },
                ),
    );
  }
} 