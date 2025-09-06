import 'package:flutter_shop/models/grocery_item.dart';
import 'package:flutter_shop/models/category.dart';
import 'package:flutter_shop/data/categories.dart';


// 初期化する際にすべて定数値であれば、constにできる。
// ただし、関数や配列から値を取得する場合は実行時に値が決まるのでfinalにする必要がある。
final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryItem(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
];
