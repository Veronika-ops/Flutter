// Библиотеки Flutter и Supabase, которые используются по всему приложению.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'second_screen.dart';

/// Точка входа во Flutter‑приложение.
Future<void> main() async {
  // WidgetsFlutterBinding гарантирует, что мы можем вызывать асинхронный код
  // до запуска приложения (например, инициализацию Supabase).
  WidgetsFlutterBinding.ensureInitialized();

  // Настраиваем соединение с нашим проектом Supabase.
  await Supabase.initialize(
    url: 'https://aogwntbdzsgncqbklofl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvZ3dudGJkenNnbmNxYmtsb2ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NTA5OTcsImV4cCI6MjA3ODMyNjk5N30.PY5nqJewgX52vFmjofUJmDj8n-QPjeWdVLK1ipI_e4Q',
  );

  // Запускаем приложение, передавая корневой виджет.
  runApp(const MyApp());
}

/// Корневой Stateless‑виджет с настройкой темы и стартового экрана.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Регистрация',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Генерируем цветовую схему на основе одного «семенного» цвета.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const RegistrationPage(),
    );
  }
}

/// Экран, на котором пользователь либо входит, либо регистрируется.
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  /// Ключ формы позволяет запускать валидацию всех полей сразу.
  final _formKey = GlobalKey<FormState>();

  /// Контроллеры сохраняют введённые пользователем значения.
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Флаг, показывающий какой режим сейчас активен: вход (false) или регистрация (true).
  bool _isRegisterMode = false;

  /// Удобный геттер, чтобы не писать Supabase.instance.client каждый раз.
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void dispose() {
    // Освобождаем ресурсы, когда виджет удаляется со сцены.
    _loginController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Полностью очищает все поля формы — удобно после выхода из аккаунта.
  void _clearFormFields() {
    _loginController.clear();
    _passwordController.clear();
    _usernameController.clear();
    _confirmPasswordController.clear();
  }

  /// Основная логика: либо регистрируем нового пользователя, либо выполняем вход.
  Future<void> _handleRegistration() async {
    // Если форма не прошла проверку, дальше ничего не делаем.
    if (!_formKey.currentState!.validate()) return;

    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isRegisterMode) {
        // Для регистрации сначала убеждаемся, что такого логина ещё нет в базе.
        final existing = await _supabase
            .from('Users')
            .select('id')
            .eq('login', login)
            .limit(1)
            .maybeSingle();
        debugPrint('Supabase check existing user: $existing');
        if (existing != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Логин уже занят'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Если логин свободен — создаём новую строку в таблице Users.
        await _supabase.from('Users').insert({
          'login': login,
          'password': password,
        });
        debugPrint('Supabase created user: $login');

        if (!mounted) return;
        // Переходим на второй экран и ждём, пока пользователь вернётся.
        final result = await Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) => const SecondScreen(),
          ),
        );
        if (result == true && mounted) {
          setState(() {
            _isRegisterMode = false;
          });
          _clearFormFields();
        }
      } else {
        // Режим входа: просто ищем совпадение логина и пароля.
        final user = await _supabase
            .from('Users')
            .select('id, login')
            .eq('login', login)
            .eq('password', password)
            .limit(1)
            .maybeSingle();
        debugPrint('Supabase login result: $user');

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Неверный логин или пароль'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (!mounted) return;
        // Переходим на второй экран и ждём возвращения результата.
        final result = await Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) => const SecondScreen(),
          ),
        );
        if (result == true && mounted) {
          setState(() {
            _isRegisterMode = false;
          });
          _clearFormFields();
        }
      }
    } catch (e) {
      // Любую ошибку Supabase/сети показываем в SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Заголовок экрана — меняется в зависимости от режима.
                Text(
                  _isRegisterMode ? 'Регистрация' : 'Вход',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegisterMode
                      ? 'Заполните форму для регистрации'
                      : 'Введите данные для входа',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Поле ввода логина (просто текст).
                TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    labelText: 'Логин',
                    hintText: 'Введите логин',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите логин';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Поле ввода пароля, символы скрываются благодаря obscureText.
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    hintText: 'Введите пароль',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль должен содержать минимум 6 символов';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (_isRegisterMode) ...[
                  // Дополнительное поле с отображаемым именем — нужно только при регистрации.
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя пользователя',
                      hintText: 'Введите имя пользователя',
                    ),
                    validator: (value) {
                      if (!_isRegisterMode) {
                        return null;
                      }
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите имя пользователя';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Проверяем, что пользователь дважды ввёл одинаковый пароль.
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Повторите пароль',
                      hintText: 'Введите пароль ещё раз',
                    ),
                    validator: (value) {
                      if (!_isRegisterMode) {
                        return null;
                      }
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, повторите пароль';
                      }
                      if (value != _passwordController.text) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ] else
                  const SizedBox(height: 24),

                // Основная кнопка — запускает либо регистрацию, либо вход.
                FilledButton(
                  onPressed: _handleRegistration,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isRegisterMode ? 'Зарегистрироваться' : 'Войти',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  // Ссылка переключает режим: «вход ↔ регистрация».
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegisterMode = !_isRegisterMode;
                      });
                    },
                    child: Text(
                      _isRegisterMode ? 'Уже есть аккаунт? Войти' : 'Создать аккаунт',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
