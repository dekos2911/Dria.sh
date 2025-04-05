#!/bin/bash

# Кольори
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

LOG_FILE="$HOME/dria.log"

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
  echo -e "${YELLOW}➡️ Починаємо встановлення ноди Dria...${NC}"

  if lsof -i :4001 >/dev/null; then
    echo -e "${RED}❌ Порт 4001 вже зайнятий!${NC}"
    return 1
  fi

  echo -e "${YELLOW}🔄 Оновлюємо систему...${NC}"
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y wget curl git jq lsof unzip

  echo -e "${YELLOW}⬇️ Встановлюємо Ollama...${NC}"
  curl -fsSL https://ollama.com/install.sh | sh

  echo -e "${YELLOW}⬇️ Встановлюємо Dria Launcher...${NC}"
  curl -fsSL https://dria.co/launcher | bash

  source ~/.bashrc
  echo -e "${GREEN}✅ Встановлення завершено!${NC}"
}

start_node() {
  echo -e "${YELLOW}🚀 Запуск ноди у screen-сесії...${NC}"

  if ! command -v dkn-compute-launcher &>/dev/null; then
    echo -e "${RED}❌ Нода не встановлена! Спочатку виконайте встановлення.${NC}"
    return 1
  fi

  # Перевіряємо, чи вже існує screen-сесія
  if screen -list | grep -q "dria_node"; then
    echo -e "${YELLOW}ℹ️ Нода вже працює у screen-сесії.${NC}"
    echo -e "${GREEN}🖥️ Щоб підключитись до сесії: screen -r dria_node${NC}"
    echo -e "${RED}❌ Щоб вийти з сесії та залишити її у фоні: натисніть Ctrl+A, потім D${NC}"
    return 0
  fi

  echo -e "${YELLOW}📡 Створюємо нову screen-сесію для запуску ноди...${NC}"

  screen -dmS dria_node bash -c "dkn-compute-launcher start 2>&1 | tee -a '$LOG_FILE'"
  echo -e "${GREEN}✅ Нода запущена у screen-сесії! Логи можна переглядати в реальному часі.${NC}"
}

stop_node() {
  echo -e "${YELLOW}🛑 Зупинка ноди...${NC}"

  PID=$(pgrep -f "dkn-compute-launcher")

  if [[ -n "$PID" ]]; then
    kill "$PID"
    echo -e "${GREEN}✅ Нода зупинена (PID: $PID)${NC}"
  else
    echo -e "${YELLOW}ℹ️ Нода вже зупинена або не знайдена.${NC}"
  fi
}

view_logs() {
  if [[ ! -f "$LOG_FILE" ]]; then
    echo -e "${RED}❌ Файл логів не знайдено. Спочатку запустіть ноду.${NC}"
    return 1
  fi

  echo -e "${YELLOW}📜 Перегляд логів (натисніть Ctrl+C для виходу):${NC}"
  tail -f "$LOG_FILE"
}

node_status() {
  echo -e "${YELLOW}📊 Перевірка статусу ноди:${NC}"

  if pgrep -f "dkn-compute-launcher" &>/dev/null; then
    echo -e "${GREEN}🟢 Нода активна (PID: $(pgrep -f dkn-compute-launcher))${NC}"
  else
    echo -e "${RED}🔴 Нода неактивна${NC}"
  fi
}

remove_node() {
  stop_node
  echo -e "${YELLOW}🗑️ Видаляємо ноду...${NC}"
  dkn-compute-launcher uninstall
  rm -rf ~/.dria "$LOG_FILE"
  echo -e "${GREEN}✅ Нода успішно видалена.${NC}"
}

show_menu() {
  clear
  show_logo
  echo -e "${GREEN}Меню Dria Node:${NC}"
  echo "1. 📥 Встановити ноду"
  echo "2. 🚀 Запустити ноду"
  echo "3. ⏹️ Зупинити ноду"
  echo "4. 📊 Статус ноди"
  echo "5. 📜 Переглянути логи"
  echo "6. 🗑️ Видалити ноду"
  echo "7. ❌ Вийти"
  echo -ne "\n${YELLOW}Ваш вибір: ${NC}"
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
    6) remove_node ;;
    7) echo -e "${GREEN}👋 До зустрічі!${NC}"; exit 0 ;;
    *) echo -e "${RED}❗ Невірний вибір!${NC}" ;;
  esac

  echo -e "\n${YELLOW}Натисніть Enter, щоб повернутись до меню...${NC}"
  read -r
done
