import 'package:flutter/material.dart';
import 'exercises/exercise1.dart';
import 'exercises/exercise2.dart';
import 'exercises/exercise3.dart';
import 'exercises/exercise4.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Exercises',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Exercise1()),
                  ),
              child: const Text('Exercise 1 - Design'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Exercise2()),
                  ),
              child: const Text('Exercise 2 - Change Background'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Exercise3()),
                  ),
              child: const Text('Exercise 3 - Calculator'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Exercise4()),
                  ),
              child: const Text('Exercise 4 - Prime Number'),
            ),
          ],
        ),
      ),
    );
  }
}
