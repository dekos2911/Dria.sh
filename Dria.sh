#!/bin/bash

show_logo() {
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
  echo "Перевіряю залежності..."
  sudo apt update && sudo apt install -y curl lsof screen jq

  echo "Спробую встановити лаунчер..."
  if ! curl -fsSL https://dex.co/launcher | bash; then
    echo "Помилка: не вдалося встановити лаунчер. Спробуйте вручну:"
    echo "curl -fsSL https://dex.co/launcher | bash"
    return 1
  fi

  echo "Додаю лаунчер у PATH..."
  source ~/.bashrc
  command -v dkn-compute-launcher || { echo "Лаунчер не знайдено!"; return 1; }

  echo "Готово! Використовуйте пункт 2 для запуску."
}

start_node() {
  if command -v dkn-compute-launcher >/dev/null; then
    dkn-compute-launcher start
  else
    echo "Помилка: лаунчер не встановлено. Спочатку виконайте пункт 1."
  fi
}

remove_node() {
  if command -v dkn-compute-launcher >/dev/null; then
    dkn-compute-launcher uninstall
  else
    echo "Лаунчер не знайдено. Видаляю вручну..."
    sudo rm -rf ~/.dex/
  fi

  if screen -list | grep -q "dexnode"; then
    screen -S dexnode -X quit
  fi
  echo "Ноду видалено."
}

while true; do
  clear
  show_logo
  echo -e "\nМеню:"
  echo "1. Встановити ноду"
  echo "2. Запустити ноду"
  echo "6. Видалити ноду"
  echo "7. Вийти"
  read -p "Вибір: " choice

  case $choice in
    1) install_node ;;
    2) start_node ;;
    6) remove_node ;;
    7) exit 0 ;;
    *) echo "Невірний вибір"; sleep 1 ;;
  esac
  read -p "Натисніть Enter для продовження..."
done
