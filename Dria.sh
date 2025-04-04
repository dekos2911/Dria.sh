#!/bin/bash

# Кольори
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_logo() {
  clear
  echo -e "${BLUE}"
  echo -e '██████╗ ███████╗██╗  ██╗ ██████╗  ███████╗'
  echo -e '██╔══██╗██╔════╝██║ ██╔╝██║   ██║ ██╔════╝'
  echo -e '██║  ██║█████╗  █████╔╝ ██║   ██║ ███████╗'
  echo -e '██║  ██║██╔══╝  ██╔═██╗ ██║   ██║ ╚════██║'
  echo -e '██████╔╝███████╗██║  ██╗╚██████╔╝ ███████║'
  echo -e '╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══════╝'
  echo -e "${NC}"
  echo -e "\nПідтримайте український проєкт DEKOS [🇺🇦]"
  echo -e "Telegram: ${BLUE}https://t.me/indusUA${NC}\n"
}

check_ports() {
  local ports=("4001" "11434")
  local busy_ports=()
  
  for port in "${ports[@]}"; do
    if lsof -i :"$port" >/dev/null; then
      busy_ports+=("$port")
    fi
  done
  
  if [ ${#busy_ports[@]} -gt 0 ]; then
    echo -e "${RED}Помилка: Наступні порти вже використовуються: ${busy_ports[*]}${NC}"
    return 1
  fi
  return 0
}

install_dependencies() {
  echo -e "\n${YELLOW}🔧 Встановлення залежностей...${NC}"
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y wget curl git jq lsof screen unzip
}

install_ollama() {
  echo -e "\n${YELLOW}🤖 Встановлення Ollama...${NC}"
  curl -fsSL https://ollama.com/install.sh | sh
  sudo systemctl enable ollama
  sudo systemctl start ollama
}

install_dria() {
  echo -e "\n${YELLOW}⚡ Встановлення Dria Launcher...${NC}"
  curl -fsSL https://dria.co/launcher | bash
  echo 'export PATH=$PATH:$HOME/.dria/bin' >> ~/.bashrc
  source ~/.bashrc
}

install_node() {
  echo -e "\n${BLUE}===[ ВСТАНОВЛЕННЯ НОДИ DEKOS ]===${NC}"
  
  if ! check_ports; then
    return 1
  fi
  
  install_dependencies
  install_ollama
  install_dria
  
  echo -e "\n${GREEN}✅ Нода DEKOS успішно встановлена!${NC}"
  echo -e "Виконайте команду: ${BLUE}source ~/.bashrc${NC} або перезапустіть термінал"
}

start_node() {
  echo -e "\n${BLUE}===[ ЗАПУСК НОДИ DEKOS ]===${NC}"
  
  if ! command -v dkn-compute-launcher >/dev/null; then
    echo -e "${RED}Помилка: Спочатку встановіть ноду!${NC}"
    return 1
  fi

  if screen -list | grep -q "dekos_node"; then
    echo -e "${YELLOW}ℹ️ Нода DEKOS вже запущена${NC}"
    return 0
  fi

  screen -dmS dekos_node bash -c 'dkn-compute-launcher start > ~/.dekos.log 2>&1'
  
  echo -e "${GREEN}✅ Нода DEKOS запущена у фоновому режимі${NC}"
  echo -e "Логи зберігаються у: ${BLUE}~/.dekos.log${NC}"
  echo -e "Для перегляду логів: ${BLUE}tail -f ~/.dekos.log${NC}"
}

stop_node() {
  echo -e "\n${BLUE}===[ ЗУПИНКА НОДИ DEKOS ]===${NC}"
  
  if screen -list | grep -q "dekos_node"; then
    screen -ls | grep dekos_node | cut -d. -f1 | xargs kill
    echo -e "${GREEN}✅ Нода DEKOS успішно зупинена${NC}"
  else
    echo -e "${YELLOW}ℹ️ Нода DEKOS не була запущена${NC}"
  fi
}

node_status() {
  echo -e "\n${BLUE}===[ СТАТУС НОДИ DEKOS ]===${NC}"
  
  # Перевірка Ollama
  if systemctl is-active --quiet ollama; then
    echo -e "🤖 Ollama: ${GREEN}активна${NC}"
  else
    echo -e "🤖 Ollama: ${RED}не активна${NC}"
  fi

  # Перевірка Dria
  if command -v dkn-compute-launcher >/dev/null; then
    echo -e "⚡ Dria Launcher: ${GREEN}встановлено${NC}"
  else
    echo -e "⚡ Dria Launcher: ${RED}не встановлено${NC}"
  fi

  # Перевірка запущених процесів
  if screen -list | grep -q "dekos_node"; then
    echo -e "🟢 Нода DEKOS: ${GREEN}працює${NC}"
    echo -e "\nОстанні логи:"
    tail -n 5 ~/.dekos.log 2>/dev/null || echo "Логи відсутні"
  else
    echo -e "🔴 Нода DEKOS: ${RED}не активна${NC}"
  fi
}

update_node() {
  echo -e "\n${BLUE}===[ ОНОВЛЕННЯ НОДИ DEKOS ]===${NC}"
  
  if command -v dkn-compute-launcher >/dev/null; then
    curl -fsSL https://dria.co/launcher | bash
    echo -e "${GREEN}✅ Dria Launcher оновлено${NC}"
  else
    echo -e "${RED}Помилка: Dria Launcher не встановлено!${NC}"
  fi
  
  if command -v ollama >/dev/null; then
    sudo systemctl stop ollama
    curl -fsSL https://ollama.com/install.sh | sh
    sudo systemctl start ollama
    echo -e "${GREEN}✅ Ollama оновлено${NC}"
  else
    echo -e "${RED}Помилка: Ollama не встановлено!${NC}"
  fi
}

remove_node() {
  echo -e "\n${BLUE}===[ ВИДАЛЕННЯ НОДИ DEKOS ]===${NC}"
  
  stop_node
  
  if command -v dkn-compute-launcher >/dev/null; then
    dkn-compute-launcher uninstall
    rm -rf ~/.dria
    echo -e "${GREEN}✅ Dria Launcher видалено${NC}"
  fi
  
  if command -v ollama >/dev/null; then
    sudo systemctl stop ollama
    sudo rm -rf /usr/local/bin/ollama ~/.ollama
    echo -e "${GREEN}✅ Ollama видалено${NC}"
  fi
  
  echo -e "\n${GREEN}✅ Ноду DEKOS успішно видалено${NC}"
}

show_menu() {
  show_logo
  echo -e "\n${BLUE}Меню керування нодою DEKOS:${NC}"
  echo "1. 📥 Встановити ноду"
  echo "2. 🚀 Запустити ноду"
  echo "3. ⏹️ Зупинити ноду"
  echo "4. 📊 Перевірити статус"
  echo "5. 🔄 Оновити ноду"
  echo "6. 🛑 Видалити ноду"
  echo "7. ❌ Вийти"
  echo -ne "\nВиберіть опцію [1-7]: "
}

while true; do
  show_menu
  read -r choice
  
  case $choice in
    1) install_node ;;
    2) start_node ;;
    3) stop_node ;;
    4) node_status ;;
    5) update_node ;;
    6) remove_node ;;
    7) exit 0 ;;
    *) echo -e "\n${RED}Невірний вибір! Спробуйте ще раз.${NC}" ;;
  esac
  
  echo -ne "\nНатисніть Enter для продовження..."
  read -r
done
