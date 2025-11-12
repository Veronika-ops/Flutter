@echo off
chcp 65001 >nul
echo Запуск Flutter проекта...
echo.

if exist "C:\FlutterSDK\flutter\bin\flutter.bat" (
    echo Flutter SDK найден
    echo Запуск в браузере Chrome/Edge...
    "C:\FlutterSDK\flutter\bin\flutter.bat" run -d chrome
) else (
    echo ОШИБКА: Flutter SDK не найден по пути C:\FlutterSDK\flutter\bin\flutter.bat
    echo.
    echo Пожалуйста, проверьте путь к Flutter SDK или добавьте Flutter в PATH
    pause
)

