import 'package:flutter_shop/models/category.dart';

class GroceryItem {
  final String id;
  final String name;
  final int quantity;
  final Category category;

 // こうすることで名前付き引数にできる（{}をつける）
 // requiredは単に必須化するだけ
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });
}