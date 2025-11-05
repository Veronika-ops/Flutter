import 'package:flutter/material.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Третий экран'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Это третий экран!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.purple,
                  child: const Text('T1', style: TextStyle(color: Colors.white)),
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: const Text('T2', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Назад на второй экран'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/', 
                  (route) => false
                );
              },
              child: const Text('На главный экран'),
            ),
          ],
        ),
      ),
    );
  }
}