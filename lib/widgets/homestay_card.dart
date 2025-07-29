import 'package:flutter/material.dart';
import '../models/homestay_model.dart';

class HomestayCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const HomestayCard({
    super.key,
    required this.homestay,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
        onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar homestay (placeholder jika tidak ada)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey[200],
                      child: const Icon(Icons.home, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      homestay.kode,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      homestay.tipeKamar,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
                        const SizedBox(height: 6),
              Row(
                children: [
                            Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                              'Rp ${homestay.hargaSewaPerHari.toStringAsFixed(0)}/malam',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                            Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                              '${homestay.jumlahKamar} kamar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                            const SizedBox(width: 12),
                            Icon(Icons.star, size: 16, color: Colors.amber[700]),
                            const SizedBox(width: 2),
                            Text('4.5', style: TextStyle(color: Colors.amber[700], fontSize: 12)),
                ],
              ),
              if (homestay.fasilitas != null && homestay.fasilitas!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                Text(
                  'Fasilitas: ${homestay.fasilitas}',
                            style: const TextStyle(
                              color: Colors.grey,
                    fontSize: 12,
                  ),
                            maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Pesan'),
                          ),
                  ),
                ],
                    ),
                  ),
              ),
            ],
          ),
        ),
          // Icon wishlist
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 