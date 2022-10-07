import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Icon(Icons.file_copy, size: 128),
        SizedBox(height: 24),
        Text(
          'No contracts',
          style: TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('اٍتمام الطلب'),
      onPressed: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'تأكيد الطلب',
            textAlign: TextAlign.center,
          ),
          contentTextStyle: const TextStyle(fontSize: 18),
          content: Container(
            padding: const EdgeInsets.all(8),
            child: const Text('''
                            عند الضغط على موافق فأنك تقوم بطلب المنتج وسيتم اعطائه لشركة التوصيل ولا يمكن التراجع عن هذا الطلب بعد ذلك، فهل انت متأكد من طلبك؛ مع ملاحظة ان تطبيق (اسم التطبيق) يجمع لك اكثر من متجر بتطبيق واحد، فهذا يعني انك اذا طلبت منتجات من اكثر من تصنيفين مختلفين فهذا يجعل اجور التوصيل × ٢، لان كل منتج يطلب من متجر مختلف؛ اجور التوصيل داخل بغداد من الفين الى خمسة الاف دينار، 
                            عند الضغط على تنفيذ الطلب سيتم افراغ محتويات العربة ويمكنك مراجعة طلباتك من خلال حسابي -> سجل الطلبات
                          ''', textAlign: TextAlign.right),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              child: const Text('اغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).primaryColor,
      )),
    );
  }
}
