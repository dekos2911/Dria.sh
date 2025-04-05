#!/bin/bash

show_logo() {
  clear
  echo -e '\033[0;31m'
  echo -e '██████╗ ███████╗██╗  ██╗ ██████╗  ███████╗'
  echo -e '██╔══██╗██╔════╝██║ ██╔╝██║   ██║ ██╔════╝'
  echo -e '██║  ██║█████╗  █████╔╝ ██║   ██║ ███████╗'
  echo -e '██║  ██║██╔══╝  ██╔═██╗ ██║   ██║ ╚════██║'
  echo -e '██████╔╝███████╗██║  ██╗╚██████╔╝ ███████║'
  echo -e '╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══════╝'
  echo -e '\e[0m'
}

install_node() {
  echo "▶ Початок встановлення ноди DEX..."
  
  # Перевірка портів
  if lsof -i :4001 | grep -q LISTEN; then
    echo "❗ Помилка: порт 4001 вже використовується"
    return 1
  fi

  # Оновлення системи
  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt install -y wget make tar screen nano unzip lz4 gcc git jq

  # Встановлення Ollama
  if ! command -v ollama >/dev/null; then
    echo "Встановлення Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh || {
      echo "❗ Не вдалося встановити Ollama"
      return 1
    }
  fi

  # Спробувати альтернативний спосіб встановлення лаунчера
  echo "Спробую альтернативний метод встановлення лаунчера..."
  if ! curl -fsSL https://dria.co/launcher | bash; then
    echo "❗ Не вдалося встановити лаунчер. Можливі рішення:"
    echo "1. Спробуйте пізніше"
    echo "2. Зверніться до підтримки Dria/DEX"
    echo "3. Встановіть лаунчер вручну"
    return 1
  fi

  source ~/.bashrc
  echo "✔ Встановлення завершено"
}

start_node() {
  if command -v dkn-compute-launcher >/dev/null; then
    echo "▶ Запуск ноди..."
    screen -dmS dexnode dkn-compute-launcher start
    echo "Нода запущена у вікні screen (dexnode)"
  else
    echo "❗ Лаунчер не знайдено. Спочатку виконайте встановлення."
  fi
}

node_status() {
  if command -v dkn-compute-launcher >/dev/null; then
    dkn-compute-launcher points
  else
    echo "Лаунчер не встановлено"
  fi
}

remove_node() {
  if command -v dkn-compute-launcher >/dev/null; then
    echo "▶ Видалення ноди..."
    dkn-compute-launcher uninstall
  fi
  
  # Додаткове очищення
  sudo rm -rf ~/.dex/
  if screen -list | grep -q "dexnode"; then
    screen -S dexnode -X quit
  fi
  echo "✔ Нода видалена"
}

view_logs() {
  echo "▶ Перевірка логів..."
  # Перевірка наявності логів, наприклад, у домашньому каталозі або в /var/log
  if [ -f "~/.dex/logs.txt" ]; then
    cat ~/.dex/logs.txt
  else
    echo "❗ Лог файли не знайдені. Перевірте, чи нода була запущена."
  fi
}

while true; do
  show_logo
  echo -e "\nМеню:"
  echo "1. Встановити ноду"
  echo "2. Запустити ноду"
  echo "3. Перевірити статус"
  echo "4. Перевірити логи"
  echo "5. Видалити ноду"
  echo "6. Вийти"
  
  read -p "Вибір: " choice
  case $choice in
    1) install_node ;;
    2) start_node ;;
    3) node_status ;;
    4) view_logs ;;
    5) remove_node ;;
    6) exit 0 ;;
    *) echo "Невірний вибір"; sleep 1 ;;
  esac
  read -p "Натисніть Enter для повернення до меню..."
done
