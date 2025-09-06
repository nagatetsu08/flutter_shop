import 'package:flutter/material.dart';
import 'package:flutter_shop/models/grocery_item.dart';
import 'package:flutter_shop/wigets/new_item.dart';


/// この画面をStatefulWidgetに変更した理由配下２点
/// 
///　・itemを追加した際に変更内容を即座に適用できるようにするため。
///　・buildメソッド以外でもcontextを使えるようにするため。（※）
///
///　※画面遷移自体はStatelessWidgetでもできるが、StateLessWidgetはStatefulWidgetと違い、
///　　いつでもcontextを参照できるわけじゃない。特にbuildメソッド以外で使用する場合は、関数の引数にuildContext contextを渡したり、
///　　それを呼び出す箇所で_addItem（context）という感じにしないとダメになる。
///
///

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = []; 


  void _addItem() async {
    // fultter内蔵のナビゲーション
    // Pushにジェネリクスを最終的にどのようなデータを得たいかを伝えることができる。（ここでは戻ってくることを想定してGroceryItem）
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem(),)
    );

    // Backボタンを押されて何も返ってこないこともあるので、nullチェックをする
    // nullの場合は、即returnをして何も変化を起こさせない
    if(newItem == null) {
      return;
    }

    // null出ない場合は、現在管理しているState変数にItemを追加して即再描画したいので、setStateを使う
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceies!!'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add)
          ),
        ],
      ),
      // ListViewを使うことでリストが最適化される
      // 表示する項目はListTileがいい
      body: ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(_groceryItems[index].name),
          // 画面で表示するインジケータ（タグ）のようなもの
          leading: Container(
            width: 24,
            height: 24,
            color: _groceryItems[index].category.color,
          ),
          // 今は数量を表しているが＞のようなアイコンを出すことも可能（タップできることを示す）
          trailing: Text(_groceryItems[index].quantity.toString()),
      ), )
    );
  }
}