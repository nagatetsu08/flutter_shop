import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shop/models/grocery_item.dart';
import 'package:flutter_shop/data/categories.dart';
import 'package:flutter_shop/wigets/new_item.dart';

import 'package:http/http.dart' as http; //別名をつけてimport

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

  // ここをfinalにしないのは、追加ではなく、ロードしたアイテム丸ごとをここに再代入したいから
  List<GroceryItem> _groceryItems = []; 

  // ローディング判定
  var _isloading = true;

  // エラーハンドリング変数
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // firebaseからデータを取得
  void _loadItems() async {
      final url = Uri.https('flutter-shop-858dd-default-rtdb.firebaseio.com', 'shoping-list.json');

      try {
        final response = await http.get(url);

        // UI変更に関係しそうな変数は全てStateで管理した方がいい
        if(response.statusCode >= 400) {
          setState(() {
            _error = 'Failed Loading';
          });
        }

        // バックエンドにデータが0件だった場合
        // firebaseの場合、0件のときは"null"という文字を返すので以下のようにしている
        if(response.body == 'null') {
          setState(() {
            _isloading = false;
          });
          return;
        }

        //返却値が、{IDキー：{キー: 値}}の形式で、値の箇所にStringやintといったいろんな方が入ってくるので、 Map<String, dynamic>となる
        final Map<String, dynamic> listData = json.decode(response.body); //json形式のデータをMap形式に変換
        final List<GroceryItem> loadedItems = [];
        for (final item in listData.entries) {
          //タイトルが一致したcategoryオブジェクトを丸ごと取得
          final category = categories.entries.firstWhere((catItem) => catItem.value.title == item.value['category']).value;
          loadedItems.add(
            GroceryItem(
              id: item.key, 
              name: item.value['name'], 
              quantity: item.value['quantity'], 
              category: category,
            ),
          );
        }
        // その変数を使ってUIの更新を伴う場合は、setStateを使う。
        // データ取得だけとか、単に計算値を返すだけという場合は、
        setState(() {
          _groceryItems = loadedItems;
          _isloading = false;
        });
      } catch (error) {
        setState(() {
          _error = 'Somethin went wrong';
        });
      }
  }

  void _addItem() async {
    // fultter内蔵のナビゲーション
    // Pushにジェネリクスを最終的にどのようなデータを得たいかを伝えることができる。（ここでは戻ってくることを想定してGroceryItem）
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem(),) //NewItemのページに行く
    );

    _loadItems();

  }

  void _removeItem(GroceryItem item) async {
    //対象の順番を取得して、あとで同じ位置に挿入できるようにする
    final index = _groceryItems.indexOf(item);

    // ローカルで保持しているデータを取り除くだけ
    setState(() {
      _groceryItems.remove(item);
    }); 

    // レクチャーと違うところとして、個人的にデータはバックエンドと整合性を取りたいのでasync await方式にしている  
    final url = Uri.https('flutter-shop-858dd-default-rtdb.firebaseio.com', 'shoping-list/${item.id}.json');
    final response = await http.delete(url);
    
    
    if(response.statusCode >= 400) {
      // 更新に失敗した時はローカルも元に戻してやる
      setState(() {
        _groceryItems.insert(index, item);
      });       
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget content = const Center(child: Text('No Items'),);

    // ロードを待っている間はこれを表示
    if(_isloading == true) {
      // ローディングスピナーのインディケーター
      content = const Center(child: CircularProgressIndicator());
    }


    if(_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            // 画面で表示するインジケータ（タグ）のようなもの
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            // 今は数量を表しているが＞のようなアイコンを出すことも可能（タップできることを示す）
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ), 
      );
    }

    if(_error != null) {
      content = Center(child: Text(_error!));
    }

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
      body: content
    );
  }
}