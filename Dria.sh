#!/bin/bash

# Функція для відображення логотипу
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

# Головне меню
show_menu() {
  clear
  show_logo
  echo -e "\nМеню управління нодою Dria:"
  echo "1. Встановити та запустити ноду"
  echo "2. Перевірити статус ноди"
  echo "3. Переглянути логи в реальному часі"
  echo "4. Зупинити ноду"
  echo "5. Вийти"
  echo -n "Виберіть пункт меню: "
}

# Функція для перегляду логів
view_logs() {
  if [ ! -f ~/dria.log ]; then
    echo "Файл логів не знайдений. Спочатку запустіть ноду."
    sleep 2
    return
  fi
  
  echo "Для виходу з перегляду натисніть Ctrl+C"
  echo "Логи оновлюються автоматично..."
  tail -f ~/dria.log
}

# Основний цикл
while true; do
  show_menu
  read choice
  
  case $choice in
    1)
      echo "Встановлення та запуск ноди..."
      bash <(curl -sSL https://raw.githubusercontent.com/dekos2911/Dria.sh/main/Dria.sh) --start | tee ~/dria.log &
      echo "Нода запущена. Логи зберігаються у ~/dria.log"
      sleep 2
      ;;
    2)
      echo "Перевірка статусу ноди..."
      if pgrep -f "dkn-compute" >/dev/null; then
        echo "Нода працює (PID: $(pgrep -f "dkn-compute"))"
      else
        echo "Нода не працює"
      fi
      sleep 2
      ;;
    3)
      view_logs
      ;;
    4)
      echo "Зупинка ноди..."
      pkill -f "dkn-compute"
      sleep 2
      ;;
    5)
      echo "Вихід..."
      exit 0
      ;;
    *)
      echo "Невірний вибір. Спробуйте ще раз."
      sleep 1
      ;;
  esac
done
