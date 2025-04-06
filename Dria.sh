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

view_logs() {
  echo -e "\nВиберіть джерело логів:"
  echo "1. Логи ноди (поточна сесія)"
  echo "2. Логи systemd (journalctl)"
  echo "3. Логи Ollama"
  echo "4. Повернутись назад"
  
  read -p "Вибір: " log_choice
  case $log_choice in
    1)
      if screen -list | grep -q "dexnode"; then
        echo "▶ Підключення до сесії ноди (для виходу: Ctrl+A, D)"
        sleep 2
        screen -r dexnode
      else
        echo "❗ Активна сесія ноди не знайдена"
        sleep 2
      fi
      ;;
    2)
      echo -e "\nЛоги systemd (для виходу: Ctrl+C):"
      journalctl -u dkn-compute-launcher -n 25 --no-pager
      read -p "Натисніть Enter для продовження..."
      ;;
    3)
      echo -e "\nЛоги Ollama:"
      if [ -f "/var/log/ollama.log" ]; then
        tail -n 25 /var/log/ollama.log
      else
        echo "Файл логів Ollama не знайдено"
      fi
      read -p "Натисніть Enter для продовження..."
      ;;
    4)
      return
      ;;
    *)
      echo "Невірний вибір"
      sleep 1
      ;;
  esac
}

install_node() {
  # ... (попередній код встановлення без змін)
}

start_node() {
  # ... (попередній код запуску без змін)
}

node_status() {
  # ... (попередній код статусу без змін)
}

remove_node() {
  # ... (попередній код видалення без змін)
}

while true; do
  show_logo
  echo -e "\nМеню:"
  echo "1. Встановити ноду"
  echo "2. Запустити ноду (інтерактивно)"
  echo "3. Перевірити логи ноди"  # Новий пункт меню
  echo "4. Перевірити статус"
  echo "5. Перевірити встановлені моделі"
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
    3)  # Новий пункт для логів
      view_logs
      ;;
    4) 
      node_status
      ;;
    5)
      if command -v dkn-compute-launcher >/dev/null; then
        dkn-compute-launcher info
      else
        echo "Лаунчер не встановлено"
      fi
      read -p "Натисніть Enter для продовження..."
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
