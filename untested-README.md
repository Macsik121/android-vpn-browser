Я внимательно проверил ваш файл `README.md`. Он содержит отличную базу, но **есть несколько несоответствий** с той структурой папок (`scripts/` и `apk/`), которую вы указали, а также с финальными версиями скриптов, которые мы с вами разработали.

Вот что нужно исправить, чтобы инструкция была идеальной:
1. **Пути к скриптам:** Если скрипты лежат в папке `scripts/`, команды должны вызывать их как `./scripts/install.sh` и `./scripts/start.sh`.
2. **Пути к APK:** Скрипт установки и команда копирования должны искать файлы в папке `apk/`.
3. **Загрузка файлов на сайты:** Из-за ограничений proot путь `/sdcard/` внутри браузера может не открыться. Мы решили это через `--bind` (привязку) папки телефона к папке `~/Downloads/Android` внутри Debian. В инструкции нужно указать именно этот путь.
4. **Симлинки для ярлыков:** Они должны указывать на `scripts/start.sh`.
5. **Полнота картины:** В README не хватает самих текстов скриптов `install.sh` и `start.sh`, чтобы человек мог полностью восстановить проект с нуля.

Ниже представлен **исправленный, полный и готовый к публикации `README.md`**. Замените им содержимое вашего файла.

---

# 📱 Изолированный браузер с VPN (Termux + Debian + X11 + Chromium)

## 📂 Структура репозитория
Перед началом работы убедитесь, что ваш репозиторий имеет следующую структуру:
```text
📁 ИМЯ_ПАПКИ_РЕПОЗИТОРИЯ/
├── 📄 README.md
├── 📄 config.json (конфигурация для sing-box)
├── 📁 scripts/
│   ├── 📄 install.sh
│   └── 📄 start.sh
└── 📁 apk/
    ├── 📦 SFA-1.12.8-arm64-v8a.apk
    ├── 📦 Termux-X11.apk
    ├── 📦 Termux-Boot.apk
    └── 📦 Termux-Widget.apk
```

---

## 🛠️ Часть 1: Подготовка Termux и клонирование

*Если Termux ещё не установлен, скачайте его из F-Droid:* https://f-droid.org/en/packages/com.termux/

1. **Установите Git** в чистом Termux:
   ```bash
   pkg update && pkg upgrade -y
   pkg install git -y
   ```
   *(Если выпадает ошибка `429 Too Many Requests`, выполните `termux-change-repo`, выберите другое зеркало (например, Grimler) и повторите).*

2. **Клонируйте репозиторий** и перейдите в папку проекта:
   ```bash
   git clone <URL_ВАШЕГО_РЕПОЗИТОРИЯ>
   cd <ИМЯ_ПАПКИ_РЕПОЗИТОРИЯ>
   ```

---

## 📦 Часть 2: Первичная установка

Дайте права на выполнение скриптам и запустите установщик:
```bash
chmod +x scripts/*.sh
./scripts/install.sh
```

**Установка APK-файлов:**
Скрипт `install.sh` автоматически скопирует все APK из папки `apk/` в память телефона.
1. Откройте файловый менеджер на телефоне, зайдите в папку **Download**.
2. Установите все 4 APK файла (SFA, Termux:X11, Boot, Widget). *Разрешите установку из неизвестных источников.*
3. **ВАЖНО:** Запустите приложения Termux:Boot и Termux:Widget по одному разу, чтобы Android их зарегистрировал.

---

## 🐧 Часть 3: Настройка Debian (Без `sudo`!)

> ⚠️ **Внимание:** В `proot-distro` вы уже являетесь `root`. Команда `sudo` здесь не существует. Все команды выполняйте без `sudo`.

*Скрипт `install.sh` уже сделал базовую настройку, но вы можете проверить её вручную, войдя в систему (обязательно с флагом `--shared-tmp`):*
```bash
proot-distro login debian --shared-tmp
```

**🇷🇺 Настройка локали и зависимостей (если скрипт не сработал):**
```bash
apt update && apt install -y chromium dbus-x11 zenity xdg-desktop-portal-gtk xclip locales termux-api
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
source ~/.bashrc
```
Выйдите из Debian обратно в Termux (команда `exit`).

---

## 🚀 Часть 4: Запуск браузера (`start.sh`)

Для запуска браузера просто выполните:
```bash
./scripts/start.sh
```
*Скрипт сам запустит X11-сервер, поднимет Chromium, привяжет папку загрузок телефона к Debian и включит блокировку сна.*

---

## 🛡️ Часть 5: Выживание в Android (Phantom Process Killer)

Android 12+ агрессивно убивает дочерние процессы (выдает `signal 9`), из-за чего Termux падает.

1. **Настройки батареи:** Настройки Android -> Приложения -> Termux (и Termux:X11) -> Батарея -> **«Без ограничений»**.
2. **Отключение убийцы процессов:**
   * **Android 14+:** Настройки -> Система -> Для разработчиков -> Включите **«Отключить ограничения дочерних процессов»**.
   * **Android 12/13 (через ADB):** В Termux выполните:
     ```bash
     pkg install android-tools -y
     # Подключитесь по Wi-Fi ADB (adb pair, adb connect) и выполните:
     adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
     adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
     adb shell settings put global settings_enable_monitor_phantom_procs false
     ```

---

## 🔗 Часть 6: Ярлык и Автозапуск

### Ярлык на рабочий стол (Termux:Widget)
1. В Termux создайте ярлык:
   ```bash
   mkdir -p ~/.shortcuts
   ln -s ~/путь/до/репозитория/scripts/start.sh ~/.shortcuts/Start-Browser
   ```
2. На рабочем столе Android добавьте виджет Termux:Widget и выберите `Start-Browser`.

### Автозапуск после перезагрузки (Termux:Boot)
1. Создайте скрипт загрузки (замените путь на ваш):
   ```bash
   mkdir -p ~/.termux/boot
   cat << 'EOF' > ~/.termux/boot/start-autovpn.sh
   #!/data/data/com.termux/files/usr/bin/bash
   sleep 15 # Ждем инициализации сети
   ~/путь/до/репозитория/scripts/start.sh
   EOF
   chmod +x ~/.termux/boot/start-autovpn.sh
   ```
2. **Sing-box автозапуск:** В приложении SFA зайдите в настройки профиля и включите **«Autostart»**. Android сам поднимет VPN при включении телефона.

---

## 📝 Часть 7: Как пользоваться и решать проблемы

### Вставка текста (особенно русского)
Стандартный `Ctrl+V` в Chromium часто ломает кириллицу.
1. Скопируйте текст в Android.
2. На панели Termux:X11 (где ESC, CTRL) сделайте **свайп влево**, появится текстовое поле.
3. Вставьте текст в это поле и нажмите «Отправить» (стрелочку).
4. *Альтернатива через консоль:* В Debian выполните `termux-clipboard-get | xclip -selection clipboard -t text/plain\;charset=utf-8`, затем жмите `Ctrl+V` в браузере.

### Как загружать файлы на сайты (Upload)
В Chromium нажмите «Загрузить файл». В окне выбора (благодаря `zenity`) введите путь **`/root/Downloads/Android`** — это ваша папка Download с телефона. Выбирайте файлы оттуда.

### Как забирать скачанные файлы (Download)
В `start.sh` прописан флаг `--bind /sdcard/Download:/root/Downloads/Android`. Поэтому **все скачанные в браузере файлы автоматически падают в папку Download вашего телефона**.

### Если экран черный, а браузер не открывается
* Убедитесь, что Debian запускается строго с флагом `--shared-tmp` (это уже прописано в `start.sh`).
* Проверьте, что APK Termux:X11 установлен и совпадает по версии с пакетом `termux-x11-nightly`.
* Предупреждение `Could not open module param file '/sys/module/mali_kbase/...'` — безвредно, игнорируйте.

---