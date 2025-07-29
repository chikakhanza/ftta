import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/homestay_model.dart';
import '../services/api_service.dart';
import '../utils/network_config.dart';
import '../widgets/robust_network_image.dart';
import 'homestay_detail.dart';
import 'booking_form.dart'; // Added import for BookingForm
import 'package:shared_preferences/shared_preferences.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Homestay> _homestays = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  Set<int> _favoriteHomestayIds = {}; // Add favorite state
  
  final List<String> _categories = [
    'Semua',
    'Standard',
    'Deluxe',
    'Suite',
  ];

  @override
  void initState() {
    super.initState();
    _loadHomestays();
    _loadFavorites(); // Load favorites when screen is initialized
  }

  Future<void> _loadHomestays() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      print('ExploreScreen: Loading homestays...');
      final homestays = await ApiService.fetchHomestays();
      print('ExploreScreen: Loaded ${homestays.length} homestays');
      
      // Debug: print first homestay data
      if (homestays.isNotEmpty) {
        print('ExploreScreen: First homestay - ${homestays.first.kode}, Price: ${homestays.first.hargaSewaPerHari}');
        print('ExploreScreen: First homestay foto - ${homestays.first.fotokamar}');
        print('ExploreScreen: First homestay image URL - ${homestays.first.getImageUrl()}');
      }
      
      setState(() {
        _homestays = homestays;
        _isLoading = false;
      });

      // Test image connectivity setelah data dimuat
      _testImageConnectivity();
    } catch (e) {
      print('ExploreScreen: Error loading homestays - $e');
      setState(() {
        _error = 'Gagal memuat data homestay: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    print('ExploreScreen: Pull to refresh triggered');
    await _loadHomestays();
  }

  Future<void> _testImageConnectivity() async {
    if (_homestays.isNotEmpty) {
      final homestay = _homestays.first;
      final imageUrl = homestay.getImageUrl();
      if (imageUrl != null) {
        print('Testing connectivity for: $imageUrl');
        final isConnected = await ApiService.testImageConnectivity(imageUrl);
        print('Image connectivity test result: $isConnected');
      }
    }
  }

  List<Homestay> get _filteredHomestays {
    List<Homestay> filtered = _homestays;

    // Filter berdasarkan kategori
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((homestay) {
        return homestay.tipeKamar.toLowerCase().contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((homestay) {
        return homestay.kode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               homestay.tipeKamar.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (homestay.fasilitas?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EAF1),
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari homestay...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Category Filters
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Homestay List
          Expanded(
            child: _isLoading
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
                              onPressed: _loadHomestays,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _filteredHomestays.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tidak ada homestay ditemukan',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tarik ke bawah untuk muat ulang',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredHomestays.length,
                              itemBuilder: (context, index) {
                              final homestay = _filteredHomestays[index];
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
                                                // Background pattern
                                                Positioned.fill(
                                                  child: _buildImageWidget(homestay),
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
                                                // Favorite button - Updated with functionality
                                                Positioned(
                                                  top: 8,
                                                  left: 8,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (homestay.id != null) {
                                                        _toggleFavorite(homestay.id!);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.9),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Icon(
                                                        _favoriteHomestayIds.contains(homestay.id)
                                                            ? Icons.favorite
                                                            : Icons.favorite_border,
                                                        color: _favoriteHomestayIds.contains(homestay.id)
                                                            ? Colors.red
                                                            : Colors.grey[600],
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
                                                // Room and rating info
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
                                                    onPressed: () async {
                                                      // Tunggu hasil dari BookingForm
                                                      final result = await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => BookingForm(homestay: homestay),
                                                        ),
                                                      );
                                                      // Jika booking berhasil, reload data
                                                      if (result == true) {
                                                        _loadHomestays();
                                                      }
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
                        ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Semua':
        return Icons.all_inclusive;
      case 'Standard':
        return Icons.bed;
      case 'Deluxe':
        return Icons.king_bed;
      case 'Suite':
        return Icons.hotel;
      default:
        return Icons.home;
    }
  }

  Widget _buildImageWidget(Homestay homestay) {
    final imageUrl = homestay.getImageUrl();
    print('Building image widget for ${homestay.kode}, URL: $imageUrl'); // Debug
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Image.asset(
          _getHomestayImage(homestay),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: FadeInImage.assetNetwork(
        placeholder: _getHomestayImage(homestay),
        image: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        imageErrorBuilder: (context, error, stackTrace) {
          return Image.asset(
            _getHomestayImage(homestay),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        },
      ),
    );
  }

  String _getHomestayImage(Homestay homestay) {
    // Gunakan gambar berdasarkan ID homestay
    switch (homestay.id % 2) {
      case 0:
        return 'assets/images/hm2.jpg';
      case 1:
      default:
        return 'assets/images/hm1.jpg';
    }
  }

  void _showRoomTypeDialog(BuildContext context, Homestay homestay) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Pilih Tipe Kamar'),
          children: [
            SimpleDialogOption(
              child: const Text('Standard Room'),
              onPressed: () {
                Navigator.pop(context);
                _goToBooking(context, homestay, 'Standard Room');
              },
            ),
            SimpleDialogOption(
              child: const Text('Deluxe Room'),
              onPressed: () {
                Navigator.pop(context);
                _goToBooking(context, homestay, 'Deluxe Room');
              },
            ),
            SimpleDialogOption(
              child: const Text('Suite Room'),
              onPressed: () {
                Navigator.pop(context);
                _goToBooking(context, homestay, 'Suite Room');
              },
            ),
          ],
        );
      },
    );
  }

  void _goToBooking(BuildContext context, Homestay homestay, String tipeKamar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingForm(
          homestay: homestay,
          initialTipeKamar: tipeKamar,
        ),
      ),
    );
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites') ?? [];
      setState(() {
        _favoriteHomestayIds = favorites.map((id) => int.parse(id)).toSet();
      });
      print('Loaded favorites: $_favoriteHomestayIds');
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = _favoriteHomestayIds.map((id) => id.toString()).toList();
      await prefs.setStringList('favorites', favorites);
      print('Saved favorites: $favorites');
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Toggle favorite status
  void _toggleFavorite(int homestayId) {
    setState(() {
      if (_favoriteHomestayIds.contains(homestayId)) {
        _favoriteHomestayIds.remove(homestayId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Homestay dihapus dari favorit'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        _favoriteHomestayIds.add(homestayId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Homestay ditambahkan ke favorit'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
    _saveFavorites(); // Save to SharedPreferences
  }
} 