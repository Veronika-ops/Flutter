import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'second_screen.dart';
import 'third_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lab Work',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Домашняя страница - ваш существующий интерфейс
      home: const MyHomePage(title: 'Flutter Laboratory Work'),
      
      // Named routes для навигации
      routes: {
        '/': (context) => const MainScreen(),
        '/second': (context) => const SecondScreen(),
        '/third': (context) => const ThirdScreen(),
      },
      
      // Начальный маршрут (опционально)
      initialRoute: '/',
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onFloatingActionButtonPressed() {
    print('Floating Action Button pressed! Counter: $_counter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Кнопка навигации в AppBar
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            tooltip: 'Перейти к навигации',
          ),
        ],
      ),
      body: Column(
        children: [
          // Первый Container (верхний)
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.red,
            child: const Center(
              child: Text(
                'Верхний Container',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Row с тремя Text виджетами
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Текст 1',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Текст 2',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Текст 3',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          // Кнопки навигации
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Базовая навигация
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecondScreen()),
                    );
                  },
                  child: const Text('2-й экран (базовая)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Named routes навигация
                    Navigator.pushNamed(context, '/second');
                  },
                  child: const Text('2-й экран (named)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/third');
                  },
                  child: const Text('3-й экран'),
                ),
              ],
            ),
          ),
          
          // Expanded с Row и CircleAvatar
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/second');
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                      child: Text(
                        'A1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/third');
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Второй Container (нижний)
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.blue,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
                child: const Text(
                  'Перейти к системе навигации',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFloatingActionButtonPressed,
        tooltip: 'Increment!!!!!!!!!!!!!!!!',
        child: const Icon(Icons.add),
      ),
    );
  }
}