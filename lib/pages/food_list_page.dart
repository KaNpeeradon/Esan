import 'package:flutter/material.dart';
import '../../widgets/food_item.dart';
import 'cart_page.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการอาหาร"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
              setState(() {});
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 10),
            Text("อาหารคาว", style: TextStyle(fontSize: 18)),

            FoodItem(
              name: "เกี๊ยวซ่า"
             ,imagePath: "assets/images/Gyoza.jpg",
            ),
            FoodItem(name: "ข้าวผัด", imagePath: "assets/images/Kawpad.jpg"),
            FoodItem(name: "ต้มยำกุ้ง", imagePath: "assets/images/Tomyam.jpg"),
            FoodItem(name: "กะเพรา", imagePath: "assets/images/Krapow.jpg"),

            SizedBox(height: 20),
            Text("ของหวาน", style: TextStyle(fontSize: 18)),

            FoodItem(
              name: "ไอติม",
              imagePath: "assets/images/Ice.jpg",
            ),
            FoodItem(
              name: "ปังปิ้ง",
              imagePath: "assets/images/Panping.jpg",
            ),
            FoodItem(name: "มาชเมลโล่", imagePath: "assets/images/Mallow.jpg"),
          ],
        ),
      ),
    );
  }
}