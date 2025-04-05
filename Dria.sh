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

install_and_start_node() {
  echo -e "${YELLOW}➡️ Починаємо встановлення та запуск ноди Dria...${NC}"

  if lsof -i :4001 >/dev/null; then
    echo -e "${RED}❌ Порт 4001 вже зайнятий!${NC}"
    return 1
  fi

  # Оновлення системи
  echo -e "${YELLOW}🔄 Оновлюємо систему...${NC}"
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y wget curl git jq lsof unzip

  # Встановлення Ollama
  echo -e "${YELLOW}⬇️ Встановлюємо Ollama...${NC}"
  curl -fsSL https://ollama.com/install.sh | sh

  # Встановлення Dria Launcher
  echo -e "${YELLOW}⬇️ Встановлюємо Dria Launcher...${NC}"
  curl -fsSL https://dria.co/launcher | bash

  source ~/.bashrc

  echo -e "${GREEN}✅ Встановлення завершено!${NC}"

  # Запуск ноди в фоновому режимі
  echo -e "${YELLOW}🚀 Запуск ноди...${NC}"
  nohup dkn-compute-launcher start > "$LOG_FILE" 2>&1 &

  echo -e "${GREEN}✅ Нода запущена в фоновому режимі! Логи зберігаються в $LOG_FILE.${NC}"
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
  echo "1. 📥 Встановити та запустити ноду"
  echo "2. ⏹️ Зупинити ноду"
  echo "3. 📊 Статус ноди"
  echo "4. 📜 Переглянути логи"
  echo "5. 🗑️ Видалити ноду"
  echo "6. ❌ Вийти"
  echo -ne "\n${YELLOW}Ваш вибір
