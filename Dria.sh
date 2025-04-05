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
  echo 'Починаю встановлення ноди...'

  cd $HOME

  sudo apt install lsof

  ports=(4001)

  for port in "${ports[@]}"; do
    if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
      echo "Помилка: Порт $port зайнятий. Неможливо продовжити."
      exit 1
    fi
  done

  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt install -y wget make tar screen nano unzip lz4 gcc git jq

  if screen -list | grep -q "dexnode"; then
    screen -ls | grep dexnode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  if [ -d "$HOME/.dex" ]; then
    dkn-compute-launcher uninstall
    sudo rm -rf .dex/
  fi

  curl -fsSL https://ollama.com/install.sh | sh

  curl -fsSL https://dex.co/launcher | bash

  source ~/.bashrc

  screen -S dexnode

  echo 'Тепер можна запустити ноду.'
}

start_node() {
  dkn-compute-launcher start
}

configure_node() {
  dkn-compute-launcher settings
}

check_points() {
  dkn-compute-launcher points
}

check_models() {
  dkn-compute-launcher info
}

remove_node() {
  dkn-compute-launcher uninstall

  if screen -list | grep -q "dexnode"; then
    screen -ls | grep dexnode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi
}

exit_script() {
  exit 0
}

while true; do
    show_logo
    sleep 2
    echo -e "\n\nМеню:"
    echo "1. 🤺 Встановити ноду"
    echo "2. 🚀 Запустити ноду"
    echo "3. ⚙️ Налаштування ноди"
    echo "4. 📊 Перевірити бали ноди"
    echo "5. 🔍 Перевірити встановлені моделі"
    echo "6. 🗑️ Видалити ноду"
    echo "7. 👋 Вийти зі скрипта"
    read -p "Виберіть пункт меню: " choice

    case $choice in
      1)
        install_node
        ;;
      2)
        start_node
        ;;
      3)
        configure_node
        ;;
      4)
        check_points
        ;;
      5)
        check_models
        ;;
      6)
        remove_node
        ;;
      7)
        exit_script
        ;;
      *)
        echo "Невірний вибір. Будь ласка, оберіть правильний пункт меню."
        ;;
    esac
  done
