import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yes Or No',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  final storage = const FlutterSecureStorage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = 'Click button to draw';
  Color _color = Colors.grey;
  int _percentage = 50;
  bool _hide = false;

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _percentage = int.parse(await widget.storage.read(key: "percentage") as String);
      setState(() {});
    });
  }
  
  void generateRandomResult() {
    setState(() {
      _result = 'Generating...';
      _color = Colors.grey;
    });
    Timer(const Duration(seconds: 1), () {
      var bool = Random().nextDouble() * 100 < _percentage;
      setState(() {
        _result = bool ? 'Yes' : 'No';
        _color = bool ? Colors.green : Colors.red;
      });
    });
  }

  void changePercentage() {
    TextEditingController percentageController =
        TextEditingController(text: '$_percentage');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("How often will yes appear?",
                          style: Theme.of(context).textTheme.labelLarge),
                      Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: SizedBox(
                              width: 240,
                              height: 80,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: percentageController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Pick % of success',
                                ),
                              ))),
                      TextButton(
                          onPressed: () {
                            setState(() {
                                _hide = !_hide;
                              });
                            },
                          child: const Text("Toggle percentage")
                      ),
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close')),
                            TextButton(
                                onPressed: () {
                                  setState(() async {
                                    _percentage =
                                        int.parse(percentageController.text);
                                    if (_percentage > 100) _percentage = 100;
                                    await widget.storage.write(key: "percentage", value: _percentage.toString());
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Save')),
                          ]),
                    ])));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(
            child: Text('Yes Or No?',
                style:  TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500))),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            const Text(
              'The result is:',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 23),
            ),
            Text(
              _result,
              style: TextStyle(
                  color: _color, fontWeight: FontWeight.bold, fontSize: 34),
            ),
          ])),
      floatingActionButton: FloatingActionButton(
          onPressed: generateRandomResult,
          tooltip: 'Draw',
          child: GestureDetector(
            onLongPress: changePercentage,
            child: !_hide ? Text("$_percentage%") : const Icon(Icons.star),
          )),
    );
  }
}
