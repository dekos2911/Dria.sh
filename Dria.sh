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
  
  if lsof -i :4001 | grep -q LISTEN; then
    echo "❗ Помилка: порт 4001 вже використовується"
    sleep 2
    return
  fi

  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt install -y wget make tar screen nano unzip lz4 gcc git jq

  if ! command -v ollama >/dev/null; then
    echo "Встановлення Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh || {
      echo "❗ Не вдалося встановити Ollama"
      sleep 2
      return
    }
  fi

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

  echo "▶ Запуск ноди в реальному часі..."
  echo "▶ Для виходу з перегляду: Ctrl+A, потім D"
  sleep 3
  screen -S dexnode -m -d bash -c "dkn-compute-launcher start; exec bash"
  screen -r dexnode
}

view_logs() {
  echo -e "\nВиберіть тип логів:"
  echo "1. Поточні логи ноди (screen)"
  echo "2. Логи systemd (journalctl)"
  echo "3. Логи Ollama"
  echo "4. Повернутись у меню"
  
  read -p "Вибір: " log_choice
  case $log_choice in
    1)
      if screen -list | grep -q "dexnode"; then
        echo "▶ Підключення до логів ноди (Ctrl+A+D для виходу)"
        sleep 2
        screen -r dexnode
      else
        echo "❗ Сесія ноди не знайдена"
        sleep 2
      fi
      ;;
    2)
      echo -e "\nОстанні 30 строк логів systemd:"
      sudo journalctl -u dkn-compute-launcher -n 30 --no-pager
      read -p "Натисніть Enter для продовження..."
      ;;
    3)
      echo -e "\nОстанні 30 строк логів Ollama:"
      if [ -f "/var/log/ollama.log" ]; then
        tail -n 30 /var/log/ollama.log
      else
        echo "Файл логів Ollama не знайдено"
      fi
      read -p "Натисніть Enter для продовження..."
      ;;
    4) return ;;
    *) echo "Невірний вибір"; sleep 1 ;;
  esac
}

node_status() {
  if command -v dkn-compute-launcher >/dev/null; then
    dkn-compute-launcher points
  else
    echo "Лаунчер не встановлено"
  fi
  read -p "Натисніть Enter для продовження..."
}

remove_node() {
  if command -v dkn-compute-launcher >/dev/null; then
    echo "▶ Видалення ноди..."
    dkn-compute-launcher uninstall
  fi
  
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
  echo "2. Запустити ноду (реальний час)"
  echo "3. Перевірити логи"
  echo "4. Перевірити статус"
  echo "5. Видалити ноду"
  echo "6. Вийти"
  
  read -p "Вибір: " choice
  case $choice in
    1) install_node ;;
    2) start_node ;;
    3) view_logs ;;
    4) node_status ;;
    5) remove_node ;;
    6) exit 0 ;;
    *) echo "Невірний вибір"; sleep 1 ;;
  esac
done
