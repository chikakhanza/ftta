import 'package:flutter/material.dart';
import '../models/homestay_model.dart';
import '../services/api_service.dart';
import 'homestay_detail.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Homestay> _homestays = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadHomestays();
  }

  Future<void> _loadHomestays() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final homestays = await ApiService.getHomestays();
      setState(() {
        _homestays = homestays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data homestay:  e.toString()';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF9B4064),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                Image.asset('assets/images/house.png', width: 48, height: 48),
                const SizedBox(height: 8),
                const Text(
                  'HOMESTAY ECOPARK SYARIAH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8EAF1),
              child: RefreshIndicator(
                onRefresh: _loadHomestays,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                        ? Center(
                            child: Text(
                              _error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : _homestays.isEmpty
                            ? const Center(
                                child: Text(
                                  'Belum ada homestay tersedia',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _homestays.length,
                                itemBuilder: (context, index) {
                                  final homestay = _homestays[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => HomestayDetailScreen(homestay: homestay),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 4,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              homestay.kode,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Color(0xFF9B4064),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              homestay.tipeKamar,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.attach_money, color: Color(0xFFB76A8A), size: 20),
                                                const SizedBox(width: 4),
                                                Text('Rp ${homestay.hargaSewaPerHari.toStringAsFixed(0)}'),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.bed, color: Color(0xFFB76A8A), size: 20),
                                                const SizedBox(width: 4),
                                                Text('${homestay.jumlahKamar} kamar'),
                                              ],
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
          ),
        ],
      ),
    );
  }
} 