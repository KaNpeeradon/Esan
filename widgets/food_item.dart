import 'package:flutter/material.dart';
import '../service/cart_service.dart';

class FoodItem extends StatelessWidget {
  final String name;
  final String imagePath;
  final int price;

  const FoodItem({
    super.key,
    required this.name,
    required this.imagePath,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(name),
        subtitle: Text("฿$price"),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () {
            CartService.addItem(name, price);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("เพิ่ม $name ลงตะกร้าแล้ว")),
            );
          },
        ),
      ),
    );
  }
}