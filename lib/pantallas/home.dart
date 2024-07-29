import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rtdata/pantallas/GTemp.dart';
import 'package:rtdata/pantallas/GHume.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  double humidity = 0, temperature = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gauge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await getData();
              await Future.delayed(const Duration(seconds: 2)); // Retraso adicional para la animación
              setState(() {
                isLoading = false;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: GTemp(temperature: temperature)),
              const Divider(height: 5),
              Expanded(child: GHume(humidity: humidity)),
              const Divider(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Temperatura: ${temperature.toStringAsFixed(1)} °C",
                      style: TextStyle(
                        color: temperature < 0 ? Colors.blue :
                        temperature <= 30 ? Colors.green :
                        Colors.red,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Humedad: ${humidity.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: humidity < 0 ? Colors.brown :
                        humidity < 50 ? Colors.yellow :
                        Colors.purple,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      temperature < 0
                          ? "Hace frío"
                          : temperature <= 30
                          ? "Temperatura agradable"
                          : "Temperatura muy alta",
                      style: TextStyle(
                        color: temperature < 0
                            ? Colors.blue
                            : temperature <= 30
                            ? Colors.green
                            : Colors.red,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      humidity < 0
                          ? "Tiempo seco"
                          : humidity < 50
                          ? "Humedad media"
                          : "Humedad alta",
                      style: TextStyle(
                        color: humidity < 0
                            ? Colors.brown
                            : humidity < 50
                            ? Colors.yellow
                            : Colors.purple,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: Container(
                color: Colors.transparent, // Cambiar a transparente
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    Timer.periodic(
      const Duration(seconds: 30),
          (timer) async {
        setState(() {
          isLoading = true;
        });
        await getData();
        await Future.delayed(const Duration(seconds: 2)); // Retraso adicional para la animación
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  Future<void> getData() async {
    final ref = FirebaseDatabase.instance.ref();
    final temp = await ref.child("Living Room/temperature/value").get();
    final humi = await ref.child("Living Room/humidity/value").get();
    if (temp.exists && humi.exists) {
      temperature = double.parse(temp.value.toString());
      humidity = double.parse(humi.value.toString());
    } else {
      temperature = -1;
      humidity = -1;
    }
    setState(() {
      isLoading = false;
    });
  }
}
