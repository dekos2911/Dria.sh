#!/bin/bash

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_logo() {
  echo -e "${RED}"
  echo -e '██████╗ ███████╗██╗  ██╗ ██████╗  ███████╗'
  echo -e '██╔══██╗██╔════╝██║ ██╔╝██║   ██║ ██╔════╝'
  echo -e '██║  ██║█████╗  █████╔╝ ██║   ██║ ███████╗'
  echo -e '██║  ██║██╔══╝  ██╔═██╗ ██║   ██║ ╚════██║'
  echo -e '██████╔╝███████╗██║  ██╗╚██████╔╝ ███████║'
  echo -e '╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══════╝'
  echo -e "${NC}"
}

install_node() {
  echo -e "${YELLOW}Починаємо встановлення ноди Dria...${NC}"
  
  # Перевірка портів
  if lsof -i :4001 >/dev/null; then
    echo -e "${RED}Помилка: Порт 4001 вже використовується!${NC}"
    return 1
  fi

  # Оновлення системи
  echo -e "${YELLOW}Оновлюємо пакети...${NC}"
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y wget curl git jq lsof screen unzip

  # Встановлення Ollama
  echo -e "${YELLOW}Встановлюємо Ollama...${NC}"
  curl -fsSL https://ollama.com/install.sh | sh

  # Встановлення Dria
  echo -e "${YELLOW}Встановлюємо Dria Launcher...${NC}"
  curl -fsSL https://dria.co/launcher | bash

  source ~/.bashrc
  echo -e "${GREEN}Нода Dria успішно встановлена!${NC}"
}

start_node() {
  echo -e "${YELLOW}Запускаємо ноду Dria...${NC}"
  
  if ! command -v dkn-compute-launcher >/dev/null; then
    echo -e "${RED}Помилка: Спочатку встановіть ноду!${NC}"
    return 1
  fi

  screen -dmS dria_node bash -c "dkn-compute-launcher start 2>&1 | tee ~/dria.log"
  echo -e "${GREEN}Нода запущена у фоновому режимі.${NC}"
  echo -e "Для перегляду логів: ${YELLOW}screen -r dria_node${NC}"
  echo -e "Для виходу з перегляду: ${YELLOW}Ctrl+A, D${NC}"
}

stop_node() {
  echo -e "${YELLOW}Зупиняємо ноду Dria...${NC}"
  
  if screen -list | grep -q "dria_node"; then
    screen -ls | grep dria_node | cut -d. -f1 | xargs kill
    echo -e "${GREEN}Нода успішно зупинена.${NC}"
  else
    echo -e "${YELLOW}Нода не була запущена.${NC}"
  fi
}

view_logs() {
  if [ ! -f ~/dria.log ]; then
    echo -e "${RED}Файл логів не знайдено. Спочатку запустіть ноду.${NC}"
    return 1
  fi
  
  echo -e "${YELLOW}Останні 20 рядків логів:${NC}"
  tail -n 20 ~/dria.log
  echo -e "\n${YELLOW}Для перегляду в реальному часі: ${GREEN}tail -f ~/dria.log${NC}"
}

node_status() {
  echo -e "${YELLOW}Статус ноди Dria:${NC}"
  
  if screen -list | grep -q "dria_node"; then
    echo -e "${GREEN}🟢 Нода працює${NC}"
    echo -e "PID: $(pgrep -f "dkn-compute")"
  else
    echo -e "${RED}🔴 Нода не працює${NC}"
  fi
}

show_menu() {
  clear
  show_logo
  echo -e "\n${GREEN}Меню управління нодою Dria:${NC}"
  echo "1. 📥 Встановити ноду"
  echo "2. 🚀 Запустити ноду"
  echo "3. ⏹️ Зупинити ноду"
  echo "4. 📊 Перевірити статус"
  echo "5. 📜 Переглянути логи"
  echo "6. 🛑 Видалити ноду"
  echo "7. ❌ Вийти"
  echo -ne "\n${YELLOW}Виберіть пункт меню: ${NC}"
}

while true; do
  show_menu
  read -r choice
  
  case $choice in
    1) install_node ;;
    2) start_node ;;
    3) stop_node ;;
    4) node_status ;;
    5) view_logs ;;
    6) 
      stop_node
      echo -e "${YELLOW}Видаляємо ноду...${NC}"
      dkn-compute-launcher uninstall
      rm -rf ~/.dria ~/dria.log
      echo -e "${GREEN}Нода успішно видалена!${NC}"
      ;;
    7) 
      echo -e "${GREEN}Дякуємо за використання!${NC}"
      exit 0
      ;;
    *) 
      echo -e "${RED}Невірний вибір! Спробуйте ще раз.${NC}"
      ;;
  esac
  
  echo -e "\n${YELLOW}Натисніть Enter для продовження...${NC}"
  read -r
done
