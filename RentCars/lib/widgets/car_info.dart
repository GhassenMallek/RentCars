import 'package:flutter/material.dart';

class CarGrid extends StatelessWidget {
  final String _name;
  final String _model;
  final String _photo;
  final int _price;

  CarGrid(
    this._name,
    this._model,
    this._photo,
    this._price,
  );

  @override
  Widget build(BuildContext context) {
    backgroundColor:
    MaterialStateProperty.all(Theme.of(context).errorColor);
    return Scaffold(
      body: SizedBox(
        height: 300,
        child: Card(
          color: Color.fromARGB(10, 132, 169, 172),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //const Icon(Icons.restore_from_trash_rounded, size: 50,),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Image.network(_photo, width: 200, height: 100),
              ),

              Container(
                  child: Column(
                textDirection: TextDirection.ltr,
                children: [
                  const Text('model :'),
                  Text(_model),
                  Text(_name),
                  Text('price per day : $_price TND'),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(88, 231, 223, 213),
                        ),
                        onPressed: () {},
                        child: IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () {},
                        )),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
