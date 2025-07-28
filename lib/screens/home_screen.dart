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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomestays();
  }

  Future<void> _fetchHomestays() async {
    final homestays = await ApiService.fetchHomestays();
    setState(() {
      _homestays = homestays;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Homestay'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _homestays.length,
              itemBuilder: (context, index) {
                final homestay = _homestays[index];
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
    );
  }
}
