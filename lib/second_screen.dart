import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Простой экран после входа: содержит навигацию по 3 вкладкам.
class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  /// Индекс выбранной вкладки в нижнем NavigationBar.
  int _currentIndex = 0;
  late Map<String, dynamic> _user;
  late final TextEditingController _carController;
  final TextEditingController _customReasonController = TextEditingController();
  final MapController _mapController = MapController();
  bool _isSavingCar = false;
  bool _isRequestFormVisible = false;
  bool _isSubmittingRequest = false;
  LatLng? _currentLocation;
  String? _selectedReason;

  static const _customReasonKey = 'custom';
  static const _defaultCenter = LatLng(55.751244, 37.618423); // Москва
  static const _reasonOptions = [
    {'value': 'Нужно прикурить', 'label': 'Нужно прикурить'},
    {'value': 'Нужен трос', 'label': 'Нужен трос'},
    {'value': 'Нужен инструмент', 'label': 'Нужен инструмент'},
    {'value': 'Нужно топливо', 'label': 'Нужно топливо'},
    {'value': _customReasonKey, 'label': 'Своя причина'},
  ];

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.user);
    _carController = TextEditingController(
      text: (_user['car'] ?? '').toString(),
    );
    _initLocation();
  }

  @override
  void dispose() {
    _carController.dispose();
    _customReasonController.dispose();
    super.dispose();
  }

  /// Заголовки AppBar для каждой вкладки.
  static const _titles = [
    'Главная',
    'Профиль',
    'Настройки',
  ];

  /// Содержимое каждой вкладки.
  List<Widget> get _pages => [
        _buildHelpMapTab(),
        _buildProfileTab(),
        const Center(
          child: Text(
            'Раздел настроек появится в будущих обновлениях',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ];

  Widget _buildHelpMapTab() {
    final mapCenter = _currentLocation ?? _defaultCenter;
    final coordsText = _currentLocation != null
        ? '${mapCenter.latitude.toStringAsFixed(5)}, ${mapCenter.longitude.toStringAsFixed(5)}'
        : 'координаты недоступны (разрешите доступ к геопозиции)';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Помощь на дороге',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 320,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.flutter_application_1',
                  ),
                  if (_currentLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ваши координаты: $coordsText',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              setState(() {
                _isRequestFormVisible = !_isRequestFormVisible;
              });
            },
            child: Text(
              _isRequestFormVisible ? 'Скрыть запрос' : 'Запросить помощь',
            ),
          ),
          if (_isRequestFormVisible) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: const InputDecoration(
                labelText: 'Причина вызова',
                border: OutlineInputBorder(),
              ),
              items: _reasonOptions
                  .map(
                    (reason) => DropdownMenuItem(
                      value: reason['value'],
                      child: Text(reason['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                  if (value != _customReasonKey) {
                    _customReasonController.clear();
                  }
                });
              },
            ),
            if (_selectedReason == _customReasonKey) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customReasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Опишите проблему',
                  hintText: 'Например, сломалось колесо',
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _canSubmitRequest ? _submitRequest : null,
              child: _isSubmittingRequest
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Подать заявку'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final username = (_user['username'] ?? '—').toString();
    final car = (_user['car'] ?? '').toString();
    final carDisplay = car.isEmpty ? 'не указан' : car;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Имя пользователя:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            'Ваш автомобиль:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            carDisplay,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _carController,
            decoration: const InputDecoration(
              labelText: 'Модель авто',
              hintText: 'Например, Tesla Model 3',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isSavingCar ? null : _saveCar,
            child: _isSavingCar
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Сохранить автомобиль'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCar() async {
    final carValue = _carController.text.trim();
    setState(() {
      _isSavingCar = true;
    });

    try {
      await _supabase
          .from('Users')
          .update({'car': carValue})
          .eq('id', _user['id']);
      setState(() {
        _user['car'] = carValue;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные об автомобиле сохранены'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось сохранить: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSavingCar = false;
      });
    }
  }

  bool get _canSubmitRequest {
    if (_selectedReason == null) return false;
    if (_isSubmittingRequest) return false;
    if (_selectedReason == _customReasonKey) {
      return _customReasonController.text.trim().isNotEmpty;
    }
    return true;
  }

  Future<void> _submitRequest() async {
    final reason = _selectedReason == _customReasonKey
        ? _customReasonController.text.trim()
        : _selectedReason!;
    final coords = _currentLocation != null
        ? '${_currentLocation!.latitude.toStringAsFixed(6)},'
            '${_currentLocation!.longitude.toStringAsFixed(6)}'
        : null;

    setState(() {
      _isSubmittingRequest = true;
    });

    try {
      await _supabase.from('request').insert({
        'car': (_user['car'] ?? '').toString(),
        'reason': reason,
        'coords': coords,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка отправлена, ожидайте помощи'),
        ),
      );
      setState(() {
        _isRequestFormVisible = false;
        _selectedReason = null;
        _customReasonController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось отправить заявку: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmittingRequest = false;
      });
    }
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      final current = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = current;
      });
      _mapController.move(current, 13);
    } catch (e) {
      debugPrint('Ошибка определения геопозиции: $e');
    }
  }

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
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
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