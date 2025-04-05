#!/bin/bash

# Кольори тексту
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Функція для відображення успішних повідомлень
success_message() {
    echo -e "${GREEN}[✅] $1${NC}"
}

# Функція для відображення інформаційних повідомлень
info_message() {
    echo -e "${CYAN}[ℹ️] $1${NC}"
}

# Функція для відображення помилок
error_message() {
    echo -e "${RED}[❌] $1${NC}"
}

# Функція для відображення попереджень
warning_message() {
    echo -e "${YELLOW}[⚠️] $1${NC}"
}

# Функція встановлення залежностей
install_dependencies() {
    info_message "Встановлення необхідних пакетів..."
    sudo apt update && sudo apt-get upgrade -y
    sudo apt install -y git make jq build-essential gcc unzip wget lz4 aria2 curl
    success_message "Залежності встановлені"
}

# Перевірка наявності curl і установка, якщо не встановлений
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi

# Очищення екрану
clear

# Відображення логотипу
curl -s https://raw.githubusercontent.com/Mozgiii9/NodeRunnerScripts/refs/heads/main/logo.sh | bash

# Функція для відображення меню
print_menu() {
    echo -e "\n${BOLD}${WHITE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${WHITE}║        🚀 КЕРУВАННЯ НОДОЮ DRIA        ║${NC}"
    echo -e "${BOLD}${WHITE}╚════════════════════════════════════════╝${NC}\n"
    
    echo -e "${BOLD}${BLUE}🔧 Доступні дії:${NC}\n"
    echo -e "${WHITE}[${CYAN}1${WHITE}] ${GREEN}➜ ${WHITE}🛠️  Встановлення ноди${NC}"
    echo -e "${WHITE}[${CYAN}2${WHITE}] ${GREEN}➜ ${WHITE}▶️  Запуск ноди${NC}"
    echo -e "${WHITE}[${CYAN}3${WHITE}] ${GREEN}➜ ${WHITE}⬆️  Оновлення ноди${NC}"
    echo -e "${WHITE}[${CYAN}4${WHITE}] ${GREEN}➜ ${WHITE}🔌 Зміна порту${NC}"
    echo -e "${WHITE}[${CYAN}5${WHITE}] ${GREEN}➜ ${WHITE}📋 Перевірка логів${NC}"
    echo -e "${WHITE}[${CYAN}6${WHITE}] ${GREEN}➜ ${WHITE}🗑️  Видалення ноди${NC}"
    echo -e "${WHITE}[${CYAN}7${WHITE}] ${GREEN}➜ ${WHITE}🚪 Вихід${NC}\n"
}

# Функція для встановлення ноди
install_node() {
    echo -e "\n${BOLD}${BLUE}⚡ Встановлення ноди Dria...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}🔄 Встановлення залежностей...${NC}"
    install_dependencies

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}📥 Завантаження встановлювача...${NC}"
    info_message "Завантаження та встановлення Dria Compute Node..."
    curl -fsSL https://dria.co/launcher | bash
    success_message "Встановлювач завантажено та виконано"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🚀 Запуск ноди...${NC}"
    dkn-compute-launcher start

    echo -e "\n${PURPLE}═════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✨ Нода успішно встановлена та запущена!${NC}"
    echo -e "${PURPLE}═════════════════════════════════════════════${NC}\n"
}

# Функція для запуску ноди як сервісу
start_node_service() {
    echo -e "\n${BOLD}${BLUE}🚀 Запуск ноди Dria як сервісу...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Створення файлу сервісу...${NC}"
    # Визначаємо ім'я поточного користувача та його домашню директорію
    USERNAME=$(whoami)
    HOME_DIR=$(eval echo ~$USERNAME)

    # Створення файлу сервісу
    sudo bash -c "cat <<EOT > /etc/systemd/system/dria.service
[Unit]
Description=Dria Compute Node Service
After=network.target

[Service]
User=$USERNAME
EnvironmentFile=$HOME_DIR/.dria/dkn-compute-launcher/.env
ExecStart=/usr/local/bin/dkn-compute-launcher start
WorkingDirectory=$HOME_DIR/.dria/dkn-compute-launcher/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"
    success_message "Файл сервісу створено"

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}🔄 Налаштування системних служб...${NC}"
    # Перезавантаження та старт сервісу
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-journald
    sleep 1
    sudo systemctl enable dria
    sudo systemctl start dria
    success_message "Сервіс налаштовано та запущено"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}📋 Перевірка логів...${NC}"
    echo -e "\n${PURPLE}═════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📝 Команда для перевірки логів:${NC}"
    echo -e "${CYAN}sudo journalctl -u dria -f --no-hostname -o cat${NC}"
    echo -e "${PURPLE}═════════════════════════════════════════════${NC}\n"

    # Перевірка логів
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Функція для оновлення ноди
update_node() {
    echo -e "\n${BOLD}${BLUE}⬆️ Оновлення ноди Dria...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/4${WHITE}] ${GREEN}➜ ${WHITE}🛑 Зупинка сервісу...${NC}"
    sudo systemctl stop dria
    sleep 3
    success_message "Сервіс зупинено"

    echo -e "${WHITE}[${CYAN}2/4${WHITE}] ${GREEN}➜ ${WHITE}📥 Завантаження оновлень...${NC}"
    sudo rm /usr/local/bin/dkn-compute-launcher 2>/dev/null
    curl -fsSL https://dria.co/launcher | bash
    sleep 3

    echo -e "${WHITE}[${CYAN}3/4${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Копіюємо бінарний файл з нового шляху в /usr/local/bin...${NC}"
    sudo cp $HOME/.dria/bin/dkn-compute-launcher /usr/local/bin/dkn-compute-launcher
    sudo chmod +x /usr/local/bin/dkn-compute-launcher
    sudo systemctl daemon-reload
    sleep 3
    success_message "Оновлення завантажено та встановлено"

    echo -e "${WHITE}[${CYAN}4/4${WHITE}] ${GREEN}➜ ${WHITE}🚀 Перезапуск сервісу...${NC}"
    sleep 3
    sudo systemctl restart dria
    success_message "Сервіс перезапущено"

    echo -e "\n${PURPLE}═════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✨ Нода успішно оновлена!${NC}"
    echo -e "${PURPLE}═════════════════════════════════════════════${NC}\n"

    # Перевірка логів
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Функція для зміни порту
change_port() {
    echo -e "\n${BOLD}${BLUE}🔌 Зміна порту ноди Dria...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}🛑 Зупинка сервісу...${NC}"
    sudo systemctl stop dria
    success_message "Сервіс зупинено"

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Налаштування нового порту...${NC}"
    # Запитуємо новий порт у користувача
    echo -e "${YELLOW}🔢 Введіть новий порт для Dria:${NC}"
    read -p "➜ " NEW_PORT

    # Шлях до файлу .env
    ENV_FILE="$HOME/.dria/dkn-compute-launcher/.env"

    # Оновлюємо порт у файлі .env
    sed -i "s|DKN_P2P_LISTEN_ADDR=/ip4/0.0.0.0/tcp/[0-9]*|DKN_P2P_LISTEN_ADDR=/ip4/0.0.0.0/tcp/$NEW_PORT|" "$ENV_FILE"
    success_message "Порт змінено на $NEW_PORT"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🚀 Перезапуск сервісу...${NC}"
    # Перезапуск сервісу
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-journald
    sudo systemctl start dria
    success_message "Сервіс перезапущено з новим портом"

    echo -e "\n${PURPLE}═════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📝 Команда для перевірки логів:${NC}"
    echo -e "${CYAN}sudo journalctl -u dria -f --no-hostname -o cat${NC}"
    echo -e "${PURPLE}═════════════════════════════════════════════${NC}\n"

    # Перевірка логів
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Функція для перевірки логів
check_logs() {
    echo -e "\n${BOLD}${BLUE}📋 Перевірка логів ноди Dria...${NC}\n"
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Функція для видалення ноди
remove_node() {
    echo -e "\n${BOLD}${RED}⚠️ Видалення ноди Dria...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/2${WHITE}] ${GREEN}➜ ${WHITE}🛑 Зупинка сервісів...${NC}"
    # Зупинка та видалення сервісу
    sudo systemctl stop dria
    sudo systemctl disable dria
    sudo rm /etc/systemd/system/dria.service
    sudo systemctl daemon-reload
    sleep 2
    success_message "Сервіси зупинено та видалено"

    echo -e "${WHITE}[${CYAN}2/2${WHITE}] ${GREEN}➜ ${WHITE}🗑️ Видалення файлів...${NC}"
    # Видалення папки ноди
    rm -rf $HOME/.dria
    rm -rf ~/dkn-compute-node
    success_message "Файли ноди видалено"

    echo -e "\n${GREEN}✅ Нода Dria успішно
