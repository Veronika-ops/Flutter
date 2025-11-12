import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'second_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://aogwntbdzsgncqbklofl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvZ3dudGJkenNnbmNxYmtsb2ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NTA5OTcsImV4cCI6MjA3ODMyNjk5N30.PY5nqJewgX52vFmjofUJmDj8n-QPjeWdVLK1ipI_e4Q',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Регистрация',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isRegisterMode = false;
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isRegisterMode) {
        // Простая регистрация: проверяем, что логин ещё не занят и создаём запись
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

        await _supabase.from('Users').insert({
          'login': login,
          'password': password,
        });
        debugPrint('Supabase created user: $login');

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SecondScreen(),
          ),
        );
      } else {
        // Вход: ищем пользователя по логину и паролю
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SecondScreen(),
          ),
        );
      }
    } catch (e) {
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
                // Заголовок
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

                // Имя
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

                // Пароль
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
                  // Имя пользователя
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

                // Подтверждение пароля
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

                // Кнопка регистрации
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
