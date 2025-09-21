import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/thing.dart';
import '../models/pin.dart';
import '../providers/stray_provider.dart';
import '../providers/pinterest_provider.dart';
import '../screens/pin_detail_screen.dart';

class ThingCard extends StatelessWidget {
  final Pin thing;
  final VoidCallback? onTap;

  const ThingCard({super.key, required this.thing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<PinterestProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap:
              onTap ??
              () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => PinDetailScreen(pin: null)));
              },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Pin Image
                  Image.network(
                    thing.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),

                  // Overlay with actions
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.transparent, Color.fromRGBO(0, 0, 0, 0.7)],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Bottom content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            thing.title,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CircleAvatar(radius: 12, backgroundImage: NetworkImage(thing.authorAvatar)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  thing.authorName,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
    );
  }
}
