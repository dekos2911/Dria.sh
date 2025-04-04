#!/bin/bash

show_logo() {
  echo -e '\033[0;34m'
  echo -e '██████╗ ███████╗██╗  ██╗ ██████╗  ███████╗'
  echo -e '██╔══██╗██╔════╝██║ ██╔╝██║   ██║ ██╔════╝'
  echo -e '██║  ██║█████╗  █████╔╝ ██║   ██║ ███████╗'
  echo -e '██║  ██║██╔══╝  ██╔═██╗ ██║   ██║ ╚════██║'
  echo -e '██████╔╝███████╗██║  ██╗╚██████╔╝ ███████║'
  echo -e '╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══════╝'
  echo -e '\e[0m'
  echo -e "\n\nПідтримайте український проєкт DEKOS [🇺🇦]"
  echo -e "Telegram: https://t.me/indusUA\n"
}

install_node() {
  echo -e "\n\033[1;34m===[ ВСТАНОВЛЕННЯ НОДИ DEKOS ]===\033[0m"
  
  # Перевірка портів
  if lsof -i :4001 >/dev/null; then
    echo -e "\033[0;31mПомилка: Порт 4001 вже використовується!\033[0m"
    return 1
  fi

  # Оновлення пакетів
  echo -e "\n🔧 Оновлюю системні пакети..."
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y wget curl git jq lsof screen unzip

  # Встановлення Ollama
  echo -e "\n🤖 Встановлюю Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh

  # Встановлення Dria
  echo -e "\n⚡ Встановлюю Dria Launcher..."
  curl -fsSL https://dria.co/launcher | bash

  # Налаштування середовища
  source ~/.bashrc
  echo -e "\n\033[0;32m✅ Нода DEKOS успішно встановлена!\033[0m"
}

start_node() {
  echo -e "\n\033[1;34m===[ ЗАПУСК НОДИ DEKOS ]===\033[0m"
  
  if ! command -v dkn-compute-launcher >/dev/null; then
    echo -e "\033[0;31mПомилка: Спочатку встановіть ноду!\033[0m"
    return 1
  fi

  screen -dmS dekos_node dkn-compute-launcher start
  echo -e "\n🔄 Нода DEKOS запущена у фоновому режимі"
  echo -e "Для перегляду використовуйте: screen -r dekos_node"
}

stop_node() {
  echo -e "\n\033[1;34m===[ ЗУПИНКА НОДИ DEKOS ]===\033[0m"
  
  if screen -list | grep -q "dekos_node"; then
    screen -ls | grep dekos_node | cut -d. -f1 | xargs kill
    echo -e "\n🛑 Нода DEKOS успішно зупинена"
  else
    echo -e "\nℹ️ Нода DEKOS не була запущена"
  fi
}

node_status() {
  echo -e "\n\033[1;34m===[ СТАТУС НОДИ DEKOS ]===\033[0m"
  
  # Перевірка Ollama
  if command -v ollama >/dev/null; then
    echo -e "🤖 Ollama: \033[0;32mвстановлено\033[0m"
    ollama list || echo "Моделі не знайдено"
  else
    echo -e "🤖 Ollama: \033[0;31mне встановлено\033[0m"
  fi

  # Перевірка Dria
  if command -v dkn-compute-launcher >/dev/null; then
    echo -e "\n⚡ Dria: \033[0;32mвстановлено\033[0m"
    dkn-compute-launcher info || echo "Інформація недоступна"
  else
    echo -e "\n⚡ Dria: \033[0;31mне встановлено\033[0m"
  fi

  # Перевірка запущених процесів
  echo -e "\n🔍 Активні процеси:"
  if screen -list | grep -q "dekos_node"; then
    echo -e "🟢 Нода DEKOS: \033[0;32mпрацює\033[0m"
  else
    echo -e "🔴 Нода DEKOS: \033[0;31mне активна\033[0m"
  fi
}

update_node() {
  echo -e "\n\033[1;34m===[ ОНОВЛЕННЯ НОДИ DEKOS ]===\033[0m"
  
  if command -v dkn-compute-launcher >/dev/null; then
    echo -e "\n🔄 Оновлюю Dria Launcher..."
    curl -fsSL https://dria.co/launcher | bash
    echo -e "\n\033[0;32m✅ Ноду DEKOS успішно оновлено!\033[0m"
  else
    echo -e "\n\033[0;31mПомилка: Dria Launcher не встановлено!\033[0m"
  fi
}

remove_node() {
  echo -e "\n\033[1;34m===[ ВИДАЛЕННЯ НОДИ DEKOS ]===\033[0m"
  
  # Зупинка процесів
  if screen -list | grep -q "dekos_node"; then
    echo "🛑 Зупиняю ноду..."
    screen -ls | grep dekos_node | cut -d. -f1 | xargs kill
  fi

  # Видалення Dria
  if command -v dkn-compute-launcher >/dev/null; then
    echo "🗑️ Видаляю Dria Launcher..."
    dkn-compute-launcher uninstall
  fi

  # Видалення Ollama
  if command -v ollama >/dev/null; then
    echo "🧹 Видаляю Ollama..."
    sudo rm -rf /usr/local/bin/ollama ~/.ollama
  fi

  # Очищення файлів
  rm -rf ~/.dria
  echo -e "\n✅ Ноду DEKOS успішно видалено"
}

show_menu() {
  clear
  show_logo
  echo -e "\nМеню керування нодою DEKOS:"
  echo "1. 📥 Встановити ноду"
  echo "2. 🚀 Запустити ноду"
  echo "3. ⏹️ Зупинити ноду"
  echo "4. 📊 Перевірити статус"
  echo "5. 🔄 Оновити ноду"
  echo "6. 🛑 Видалити ноду"
  echo "7. ❌ Вийти"
  echo -ne "\nВиберіть опцію [1-7]: "
}

while true; do
  show_menu
  read -r choice
  
  case $choice in
    1) install_node ;;
    2) start_node ;;
    3) stop_node ;;
    4) node_status ;;
    5) update_node ;;
    6) remove_node ;;
    7) exit 0 ;;
    *) echo -e "\n\033[0;31mНевірний вибір!\033[0m Спробуйте ще раз." ;;
  esac
  
  echo -ne "\nНатисніть Enter для продовження..."
  read -r
done
