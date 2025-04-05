#!/bin/bash

channel_logo() {
  echo -e '\033[0;31m'
  echo -e '██████╗ ███████╗██╗  ██╗ ██████╗  ███████╗'
  echo -e '██╔══██╗██╔════╝██║ ██╔╝██║   ██║ ██╔════╝'
  echo -e '██║  ██║█████╗  █████╔╝ ██║   ██║ ███████╗'
  echo -e '██║  ██║██╔══╝  ██╔═██╗ ██║   ██║ ╚════██║'
  echo -e '██████╔╝███████╗██║  ██╗╚██████╔╝ ███████║'
  echo -e '╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══════╝'
  echo -e '\e[0m'
}

setup_logging() {
  LOG_FILE="$HOME/dria_node.log"
  touch $LOG_FILE
}

download_node() {
  echo 'Починаю встановлення ноди...'

  cd $HOME
  setup_logging

  sudo apt install lsof -y

  ports=(4001)
  for port in "${ports[@]}"; do
    if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
      echo "Помилка: Порт $port зайнятий. Програма не зможе виконатись." | tee -a $LOG_FILE
      exit 1
    fi
  done

  sudo apt-get update -y && sudo apt-get upgrade -y | tee -a $LOG_FILE
  sudo apt install -y wget make tar screen nano unzip lz4 gcc git jq | tee -a $LOG_FILE

  if screen -list | grep -q "drianode"; then
    screen -ls | grep drianode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  if [ -d "$HOME/.dria" ]; then
    dkn-compute-launcher uninstall | tee -a $LOG_FILE
    sudo rm -rf .dria/
  fi

  curl -fsSL https://ollama.com/install.sh | sh | tee -a $LOG_FILE
  curl -fsSL https://dria.co/launcher | bash | tee -a $LOG_FILE

  source ~/.bashrc

  echo 'Ноду встановлено. Тепер можете запустити її через меню.' | tee -a $LOG_FILE
}

launch_node() {
  setup_logging
  echo "Запуск ноди... Логи записуються у $LOG_FILE" | tee -a $LOG_FILE
  screen -S drianode -dm bash -c "dkn-compute-launcher start | tee -a $LOG_FILE"
  echo "Нода запущена у фоновому режимі. Використовуйте пункт 'Переглянути логи' для моніторингу."
}

view_logs() {
  if [ ! -f "$HOME/dria_node.log" ]; then
    echo "Файл логів не знайдено. Спочатку запустіть ноду."
    return
  fi
  
  echo "Для виходу з перегляду логів натисніть Ctrl+C"
  echo "Для приховування логів (без зупинки ноди) натисніть Ctrl+A D"
  sleep 2
  screen -r drianode
}

settings_node() {
  dkn-compute-launcher settings
}

node_points() {
  dkn-compute-launcher points
}

models_check() {
  dkn-compute-launcher info
}

delete_node() {
  dkn-compute-launcher uninstall | tee -a $LOG_FILE

  if screen -list | grep -q "drianode"; then
    screen -ls | grep drianode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi
  
  [ -f "$HOME/dria_node.log" ] && rm "$HOME/dria_node.log"
  echo "Ноду видалено." | tee -a $LOG_FILE
}

exit_from_script() {
  exit 0
}

while true; do
    clear
    channel_logo
    echo -e "\n\nМеню:"
    echo "1. Встановити ноду"
    echo "2. Запустити ноду"
    echo "3. Переглянути логи"
    echo "4. Налаштування ноди"
    echo "5. Перевірити бали ноди"
    echo "6. Перевірити встановлені моделі"
    echo "7. Видалити ноду"
    echo "8. Вийти з скрипту"
    read -p "Виберіть пункт меню: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        launch_node
        ;;
      3)
        view_logs
        ;;
      4)
        settings_node
        ;;
      5)
        node_points
        ;;
      6)
        models_check
        ;;
      7)
        delete_node
        ;;
      8)
        exit_from_script
        ;;
      *)
        echo "Невірний пункт. Будь ласка, виберіть правильний номер з меню."
        sleep 2
        ;;
    esac
done
