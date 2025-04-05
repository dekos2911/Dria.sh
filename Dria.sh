#!/bin/bash

download_node() {
  echo 'Починаю встановлення ноди...'

  cd $HOME

  sudo apt install lsof

  ports=(4001)

  for port in "${ports[@]}"; do
    if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
      echo "Помилка: Порт $port зайнятий. Програма не зможе виконатись."
      exit 1
    fi
  done

  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt install -y wget make tar screen nano unzip lz4 gcc git jq

  if screen -list | grep -q "drianode"; then
    screen -ls | grep drianode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  if [ -d "$HOME/.dria" ]; then
    dkn-compute-launcher uninstall
    sudo rm rf .dria/
  fi

  curl -fsSL https://ollama.com/install.sh | sh

  curl -fsSL https://dria.co/launcher | bash

  source ~/.bashrc

  screen -S drianode

  echo 'Тепер запускайте ноду.'
}

launch_node() {
  dkn-compute-launcher start
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
  dkn-compute-launcher uninstall

  if screen -list | grep -q "drianode"; then
    screen -ls | grep drianode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi
}

exit_from_script() {
  exit 0
}

while true; do
    sleep 2
    echo -e "\n\nМеню:"
    echo "1. 🤺 Встановити ноду"
    echo "2. 🚀 Запустити ноду"
    echo "3. ⚙️ Налаштування ноди"
    echo "4. 📊 Перевірити очки ноди"
    echo "5. 🔍 Перевірити встановлені моделі"
    echo "6. 🗑️ Видалити ноду"
    echo "7. 👋 Вийти зі скрипта"
    read -p "Виберіть пункт меню: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        launch_node
        ;;
      3)
        settings_node
        ;;
      4)
        node_points
        ;;
      5)
        models_check
        ;;
      6)
        delete_node
        ;;
      7)
        exit_from_script
        ;;
      *)
        echo "Невірний пункт. Будь ласка, виберіть правильну цифру в меню."
        ;;
    esac
done
