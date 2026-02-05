import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/cart_item.dart';

class SaleService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ กดสั่งซื้อ -> สร้าง orders 1 ใบ + items หลายรายการ (subcollection) อัตโนมัติ
  static Future<void> saveCart(List<CartItem> items) async {
    print("🔥 saveCart called, items=${items.length}");

    if (items.isEmpty) {
      print("❌ items ว่าง เลยไม่บันทึก");
      return;
    }

    try {
      final int netPrice =
          items.fold(0, (sum, i) => sum + (i.price * i.qty));
      print("🔥 netPrice=$netPrice");

      // 1) สร้าง order หลัก
      final orderRef = await _db.collection('orders').add({
        'net_price': netPrice,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ order created id=${orderRef.id}");

      // 2) สร้างรายการขาย (items) ใต้ order
      final batch = _db.batch();
      for (final item in items) {
        final doc = orderRef.collection('items').doc(); // auto-id
        batch.set(doc, {
          'item': item.name,
          'price': item.price,
          'pc': item.qty,
          'total': item.price * item.qty,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print("✅ items batch committed");
    } catch (e, st) {
      print("🚨 Firestore error: $e");
      print(st);
      rethrow; // ส่ง error กลับไปให้ปุ่มโชว์
    }
  }
}