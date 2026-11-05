#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[1/4] Установка зависимостей Termux и репозитория X11..."
pkg update -y && pkg upgrade -y
pkg install -y x11-repo proot-distro curl termux-api android-tools

echo "[2/4] Обновление списков и установка Termux:X11..."
pkg update -y
pkg install -y termux-x11-nightly

echo "[3/4] Установка Debian и зависимостей..."
if ! proot-distro list | grep -q "debian (installed)"; then
    proot-distro install debian
fi

proot-distro login debian --shared-tmp -- apt update -y
proot-distro login debian --shared-tmp -- apt install -y chromium dbus-x11 zenity xdg-desktop-portal-gtk xclip locales

# Настройка локалей и папок внутри Debian
proot-distro login debian --shared-tmp -- bash -c '
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "export LANG=en_US.UTF-8" >> /root/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc
mkdir -p /root/Downloads/Android
'

echo "[4/4] Настройка памяти и копирование APK..."
# Добавляем || true, чтобы скрипт не упал, если пользователь не дал доступ
termux-setup-storage || true
sleep 2

# Проверяем, существует ли папка apk и есть ли в ней файлы
if [ -d "apk" ] && [ "$(ls -A apk)" ]; then
    cp apk/*.apk ~/storage/downloads/
    echo "✅ APK файлы скопированы в папку Download."
else
    echo "⚠️ Внимание: папка 'apk' пуста или не существует. Скопируйте APK вручную."
fi

echo "=================================================="
echo "✅ Установка завершена!"
echo "➡️  Откройте файловый менеджер телефона, зайдите в папку 'Download' и установите все APK."
echo "➡️  Включите VPN в приложении SFA."
echo "➡️  Для запуска браузера выполните: ./scripts/start.sh"
echo "=================================================="