import 'package:flutter/material.dart';
import '../models/homestay_model.dart';
import '../services/api_service.dart';
import 'homestay_detail.dart';
import '../widgets/homestay_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Homestay> _homestays = [];
  List<Homestay> _filteredHomestays = [];
  bool _isLoading = true;

  // Filter/search state
  String _searchQuery = '';
  double? _minHarga;
  double? _maxHarga;
  String? _selectedTipe;
  String? _selectedFasilitas;

  @override
  void initState() {
    super.initState();
    _fetchHomestays();
  }

  Future<void> _fetchHomestays() async {
    final homestays = await ApiService.fetchHomestays();
    setState(() {
      _homestays = homestays;
      _filteredHomestays = homestays;
      _isLoading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredHomestays = _homestays.where((h) {
        final matchSearch = _searchQuery.isEmpty ||
            h.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            h.tipeKamar.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchMin = _minHarga == null || h.harga >= _minHarga!;
        final matchMax = _maxHarga == null || h.harga <= _maxHarga!;
        final matchTipe = _selectedTipe == null || _selectedTipe == '' || h.tipeKamar == _selectedTipe;
        final matchFasilitas = _selectedFasilitas == null ||
            _selectedFasilitas == '' ||
            (h.fasilitas?.toLowerCase().contains(_selectedFasilitas!.toLowerCase()) ?? false);
        return matchSearch && matchMin && matchMax && matchTipe && matchFasilitas;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tipeKamarList = _homestays.map((h) => h.tipeKamar).toSet().toList();
    final fasilitasList =
        _homestays.map((h) => h.fasilitas ?? '').where((f) => f.isNotEmpty).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Homestay'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari homestay atau tipe kamar...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilter();
                    },
                  ),
                ),
                // Filter bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      // Min harga
                      Flexible(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Min Harga',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            _minHarga = double.tryParse(val);
                            _applyFilter();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Max harga
                      Flexible(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Max Harga',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            _maxHarga = double.tryParse(val);
                            _applyFilter();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tipe kamar
                      Flexible(
                        child: DropdownButton<String>(
                          value: _selectedTipe ?? '',
                          hint: const Text('Tipe'),
                          isExpanded: true,
                          items: [const DropdownMenuItem<String>(value: '', child: Text('Semua'))] +
                              tipeKamarList
                                  .map((t) => DropdownMenuItem<String>(
                                        value: t,
                                        child: Text(t),
                                      ))
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedTipe = val;
                              _applyFilter();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Fasilitas
                      Flexible(
                        child: DropdownButton<String>(
                          value: _selectedFasilitas ?? '',
                          hint: const Text('Fasilitas'),
                          isExpanded: true,
                          items: [const DropdownMenuItem<String>(value: '', child: Text('Semua'))] +
                              fasilitasList
                                  .map((f) => DropdownMenuItem<String>(
                                        value: f,
                                        child: Text(f),
                                      ))
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedFasilitas = val;
                              _applyFilter();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // List homestay
                Expanded(
                  child: _filteredHomestays.isEmpty
                      ? const Center(child: Text('Tidak ada homestay yang cocok.'))
                      : ListView.builder(
                          itemCount: _filteredHomestays.length,
                          itemBuilder: (context, index) {
                            final homestay = _filteredHomestays[index];
                            return HomestayCard(
                              homestay: homestay,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomestayDetailScreen(homestay: homestay),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
