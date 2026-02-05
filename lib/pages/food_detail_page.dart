import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../data/food_data.dart';
import '../../service/location_service.dart';
import '../../service/cart_service.dart';

class FoodDetailPage extends StatefulWidget {
  final String name;

  const FoodDetailPage({
    super.key,
    required this.name,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  String gpsText = "กำลังหาตำแหน่ง...";
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await loadLocation();
    initVideo();
  }

  void initVideo() {
    final food = FoodData.foods[widget.name];
    if (food == null || food["video"] == null) return;

    _controller = VideoPlayerController.asset(food["video"])
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> loadLocation() async {
    try {
      final food = FoodData.foods[widget.name];
      if (food == null) return;

      final pos = await LocationService.getCurrentLocation();
      final dist = LocationService.distanceKm(
        pos.latitude,
        pos.longitude,
        food["lat"],
        food["lng"],
      );

      if (!mounted) return;

      setState(() {
        gpsText =
            "พิกัดปัจจุบัน: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}\n"
            "ระยะทางถึงร้าน: ${dist.toStringAsFixed(2)} กม.";
      });
    } catch (_) {
      setState(() {
        gpsText = "ไม่สามารถระบุตำแหน่งได้";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = FoodData.foods[widget.name];

    if (food == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบข้อมูลอาหาร")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🎥 VIDEO
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),

            if (_controller != null)
              Center(
                child: IconButton(
                  iconSize: 40,
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                    });
                  },
                ),
              ),

            const SizedBox(height: 12),
            Text(gpsText),

            const SizedBox(height: 16),
            const Text(
              "วัตถุดิบ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...List<Widget>.from(
              food["ingredients"].map((i) => Text("• $i")),
            ),

            const SizedBox(height: 16),
            const Text(
              "วิธีทำ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...List<Widget>.from(
              food["steps"].map((s) => Text("- $s")),
            ),

            const SizedBox(height: 24),

            /// 🧭 MAP
            ElevatedButton.icon(
              icon: const Icon(Icons.navigation),
              label: const Text("นำทางไปยังร้าน"),
              onPressed: () async {
                final uri = Uri.parse(
                  "https://www.google.com/maps/dir/?api=1"
                  "&destination=${food["lat"]},${food["lng"]}",
                );

                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            /// 🛒 CART
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text("เพิ่มลงตะกร้า"),
              onPressed: () {
                CartService.addItem(widget.name, food["price"]);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("เพิ่มลงตะกร้าแล้ว")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
