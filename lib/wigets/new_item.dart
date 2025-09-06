import 'package:flutter/material.dart';
import 'package:flutter_shop/data/categories.dart';
import 'package:flutter_shop/models/category.dart';
import 'package:flutter_shop/models/grocery_item.dart';

// 状態管理の必要があるためStatefulWiget
class NewItem extends StatefulWidget {
  const NewItem({super.key});

 
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  
  // flutterでフォームを操作するために必要となるキー
  // これがあることでフォームの状態を保持し、フォームにいつでもアクセスできるようになる
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;


  /// 下記functionが動くと、新しいItemを作成しつつ、前の画面に戻る。
  /// 前画面では値を受け取ってから動く必要があるので、前画面の呼び出し関数にasync awaitを使う必要がある。（この画面では必要ない）
  /// 
  
  void _saveItem() {
    
    //formKeyと下のFormが結びついているので、currentStateでそのときのForm状態を取得できる。
    //ただし、最後に!をつけて、フォーム自体がnullでないことを明示する必要がある。（これはルールのようなもの）
    //validateメソッドはフォームに自動的にアクセスし、中で定義されているvalidateを実行してくれる 
    //全て通過したらtrue,ひっかかったらfalseが返ってくる
    if(_formKey.currentState!.validate()) {
      // これが実行されると、各フォームパラメータ内でonSaved関数が実行される
      _formKey.currentState!.save();

      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName, 
          quantity: _enteredQuantity, 
          category: _selectedCategory
        )
      ); //前の画面に戻る
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item')
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if(value == null || 
                     value.isEmpty || 
                     value.trim().length <= 1 ||
                     value.trim().length > 50) {
                    
                    return '2文字以上50文字以内で入力してください';
                  }
                  return null; // nullを返すことはvalidationが成功したことを意味する
                },
                // onSavedでは、追加チェックをしたり、別の変数に値を入れたりと、副作用を定義できる
                onSaved: (value) {
                  // 保存に成功した値を取得
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end, //行に対してのCrossAxisAlignmentなので、縦方向にきく
                /// Expandを使っている理由
                /// 
                /// TextFormFieldをrowで利用する場合、ExpandedやFlexibleで幅の制約を与えないと「レンダリングエラー」が起こる。
                /// これは「Rowの子には幅制約が与えられないため、TextFormFieldが無限幅（unbounded width）でレイアウトしようとして失敗する」ため
                /// その配下で使われているInputDecoratorは、「具体的な幅」がないとレンダリングできないのでエラーとなる
                /// Expandをいれることで、Row全体のうち余っている幅をこの子に全部渡すよという意味になる。
                ///
                children: [
                  Expanded(child: 
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: '1', //数値としての扱いでもForm内はすべてStringで定義する必要がある
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if(value == null || 
                          value.isEmpty || 
                          int.tryParse(value) == null || //数値変換に失敗した場合はnullを返す
                          int.tryParse(value)! <= 0 ) { //!を最後につけるとこいつがnullでないことを保証する。（上のバリデーションをスルーしているので必ずフォーマットできている）

                          return '1以上を入力してください';
                        }
                        return null; // nullを返すことはvalidationが成功したことを意味する
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: 
                    DropdownButtonFormField(
                      initialValue: _selectedCategory,
                      items: [
                        // map形式が複数ある場合（map形式の場合）通常ではforループで回せないので、.entriesで連想配列に変換している
                        for (final category in categories.entries) 
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container (
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title)
                              ]
                            ), 
                          ),
                      ], 
                      onChanged: (value) {
                        // 表示自体はonChangeなしでも変わる。
                        // ただ、内部もっている状態（何を今選んだが）はsetStateを使わないと更新されない
                        // TextFormFieldはこの仕組み自体を内部にもっているので、setStateを使わなくても大丈夫らしい
                        setState(() {
                          _selectedCategory = value!;
                        });
                        
                      }
                    )
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                // Rowに対するmainAxisAlignmentなので横方向にきく
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    }, 
                    child: const Text('Rest')
                  ), // 画面の内容をリセットするボタン
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Add')),  // フォームを送信するボタン
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}