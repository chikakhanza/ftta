import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'homestay_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openMaps() async {
    const lat = -6.2088;
    const lng = 106.8456;
    const homestayName = 'Homestay Ecopark Syariah';
    
    print('Opening maps for: $homestayName at $lat, $lng'); // Debug print
    
    final urls = [
      'https://maps.google.com/maps?q=$lat,$lng($homestayName)',
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      'geo:$lat,$lng?q=$homestayName',
    ];
    
    for (final url in urls) {
      try {
        print('Trying URL: $url'); // Debug print
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('Successfully launched: $url'); // Debug print
          return;
        } else {
          print('Cannot launch URL: $url'); // Debug print
        }
      } catch (e) {
        print('Error launching URL $url: $e'); // Debug print
      }
    }
    
    // Fallback: open in browser
    try {
      final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      final uri = Uri.parse(fallbackUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('Launched fallback URL: $fallbackUrl'); // Debug print
    } catch (e) {
      print('Error launching fallback URL: $e'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EAF1),
      body: SingleChildScrollView(
        child: Column(
        children: [
            // Banner Promo
          Container(
            width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A4C93), Color(0xFF8B5CF6)],
                ),
              ),
                        child: Stack(
                          children: [
                  // Background image atau pattern
                            Container(
                              decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/hm1.jpg'),
                        fit: BoxFit.cover,
                        opacity: 0.3,
                                ),
                              ),
                            ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Promo Spesial!',
                  style: TextStyle(
                    color: Colors.white,
                            fontSize: 24,
                    fontWeight: FontWeight.bold,
                          ),
                  ),
                  const SizedBox(height: 8),
                        const Text(
                          'Diskon hingga 50% untuk booking homestay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomestayListScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6A4C93),
                          ),
                          child: const Text('Lihat Promo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Informasi Homestay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.home, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Homestay Ecopark Syariah',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Tempat menginap yang nyaman dan aman',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(
                              'Jl. Ecopark Syariah No. 123, Jakarta',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            '4.8/5.0',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.phone, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '+62 21 1234 5678',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                                              ],
                                            ),
                                          ],
                                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tombol Lihat di Maps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _openMaps,
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'Lihat di Maps',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Informasi Tentang Homestay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang Homestay Ecopark Syariah',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Fasilitas Utama
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fasilitas Utama',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFacilityRow(Icons.wifi, 'WiFi Gratis'),
                          _buildFacilityRow(Icons.tv, 'TV LED'),
                          _buildFacilityRow(Icons.ac_unit, 'AC'),
                          _buildFacilityRow(Icons.local_parking, 'Parkir Luas'),
                          _buildFacilityRow(Icons.security, 'Keamanan 24 Jam'),
                          _buildFacilityRow(Icons.restaurant, 'Restaurant'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Keunggulan
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keunggulan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAdvantageRow(Icons.location_on, 'Lokasi Strategis', 'Dekat dengan pusat kota dan tempat wisata'),
                          _buildAdvantageRow(Icons.people, 'Ramah Keluarga', 'Cocok untuk liburan keluarga'),
                          _buildAdvantageRow(Icons.star, 'Rating Tinggi', '4.8/5.0 dari ratusan review'),
                          _buildAdvantageRow(Icons.attach_money, 'Harga Terjangkau', 'Mulai dari Rp 300.000/malam'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Jam Operasional
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jam Operasional',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey[600]),
                              const SizedBox(width: 12),
                              const Text(
                                '24 Jam',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey[600]),
                              const SizedBox(width: 12),
                              const Text(
                                'Check-in: 14:00 | Check-out: 12:00',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityRow(IconData icon, String facility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            facility,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantageRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
