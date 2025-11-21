import 'package:flutter/material.dart';

/// Простой экран после входа: содержит навигацию по 3 вкладкам.
class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  /// Индекс выбранной вкладки в нижнем NavigationBar.
  int _currentIndex = 0;

  /// Заголовки AppBar для каждой вкладки.
  static const _titles = [
    'Главная',
    'Профиль',
    'Настройки',
  ];

  /// Содержимое каждой вкладки. Здесь пока простые заглушки.
  static const _pages = [
    Center(
      child: Text(
        'Вы успешно вошли!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    ),
    Center(
      child: Text(
        'Раздел профиля будет доступен позже',
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    ),
    Center(
      child: Text(
        'Раздел настроек появится в будущих обновлениях',
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Убираем стандартную стрелку и показываем понятную кнопку выхода.
        automaticallyImplyLeading: false,
        leadingWidth: 160,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Выйти из аккаунта',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(_titles[_currentIndex]),
      ),
      // AnimatedSwitcher плавно меняет содержимое при переключении вкладок.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}