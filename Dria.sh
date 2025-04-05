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
    sleep 2
    return
  fi

  # Оновлення системи
  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt install -y wget make tar screen nano unzip lz4 gcc git jq

  # Встановлення Ollama
  if ! command -v ollama >/dev/null; then
    echo "Встановлення Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh || {
      echo "❗ Не вдалося встановити Ollama"
      sleep 2
      return
    }
  fi

  # Встановлення лаунчера
  echo "Спробую встановити лаунчер..."
  if ! curl -fsSL https://dria.co/launcher | bash; then
    echo "❗ Не вдалося встановити лаунчер автоматично"
    echo "Спробуйте встановити його вручну:"
    echo "curl -fsSL https://dria.co/launcher | bash"
    sleep 3
    return
  fi

  source ~/.bashrc
  echo "✔ Встановлення завершено успішно!"
  sleep 2
}

start_node() {
  if ! command -v dkn-compute-launcher >/dev/null; then
    echo "❗ Лаунчер не знайдено. Спочатку виконайте встановлення."
    sleep 2
    return
  fi

  echo "▶ Запуск ноди..."
  echo "▶ Ви будете бачити хід роботи ноди у вікні screen"
  echo "▶ Для виходу з режиму перегляду (без зупинки ноди):"
  echo "   Натисніть Ctrl+A, потім D"
  echo "▶ Для повернення до перегляду: screen -r dexnode"
  echo -e "\nЗапускаю ноду через 5 секунд..."
  sleep 5

  # Запускаємо ноду у інтерактивному режимі screen
  screen -S dexnode -m -d bash -c "dkn-compute-launcher start; exec bash"
  screen -r dexnode
}

node_status() {
  if command -v dkn-compute-launcher >/dev/null; then
    dkn-compute-launcher points
    read -p "Натисніть Enter для продовження..."
  else
    echo "Лаунчер не встановлено"
    sleep 2
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
  echo "✔ Нода видалена успішно!"
  sleep 2
}

while true; do
  show_logo
  echo -e "\nМеню:"
  echo "1. Встановити ноду"
  echo "2. Запустити ноду (інтерактивно)"
  echo "4. Перевірити статус"
  echo "6. Видалити ноду"
  echo "7. Вийти"
  
  read -p "Вибір: " choice
  case $choice in
    1) 
      install_node
      ;;
    2) 
      start_node
      ;;
    4) 
      node_status
      ;;
    6) 
      remove_node
      ;;
    7) 
      exit 0
      ;;
    *) 
      echo "Невірний вибір"
      sleep 1
      ;;
  esac
done
