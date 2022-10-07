import 'package:flutter/material.dart';

class rentedCarListGrid extends StatelessWidget {
  final String _name;
  final String _model;
  final String _photo;

  rentedCarListGrid(
    this._name,
    this._model,
    this._photo,
  );

  @override
  Widget build(BuildContext context) {
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
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
