#!/bin/bash

# ----------------------------
# Color and Icon Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_RESTART="🔄"
ICON_CHECK="✅"
ICON_LOG_OP_NODE="📄"
ICON_LOG_EXEC_CLIENT="📄"
ICON_DISABLE="⏹️"
ICON_EXIT="❌"
ICON_WALLLET="🔐"

# ----------------------------
# Function to display ASCII logo and social links
# ----------------------------
display_header() {
    clear
    echo -e "    ${RED}    W I N G S  N O D E   T E A M! ${RESET}"
    echo -e "    ${GREEN}                                              ${RESET}"
    echo -e "    ${BLUE}    ${RESET}"
    echo -e "    ${YELLOW}   ${RESET}"
    echo -e "    ${MAGENTA}   ${RESET}"
    echo -e "    ${MAGENTA}${ICON_TELEGRAM} Follow us on Telegram: https://t.me/wingsnodeteam${RESET}"
    echo -e "    ${MAGENTA}📢 Follow us on Twitter: https://x.com/wingsnodeteam${RESET}"
    echo -e ""
    echo -e "${GREEN}Welcome to the Unichain (Uniswap) Node Management Interface!${RESET}"
    echo -e ""
}

# ----------------------------
# Draw Menu Borders
# ----------------------------
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
}


# ----------------------------
# Show Menu
# ----------------------------
show_menu() {
    display_header
    draw_top_border
    echo -e "    ${YELLOW}Please choose an option:${RESET}"
    draw_middle_border
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Install node"
    echo -e "    ${CYAN}2.${RESET} ${ICON_RESTART} Restart node"
    echo -e "    ${CYAN}3.${RESET} ${ICON_CHECK} Check node"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOG_OP_NODE} Check logs of Uniswap node OP Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_LOG_EXEC_CLIENT} Check logs of Uniswap node Execution Client"
    echo -e "    ${CYAN}6.${RESET} ${ICON_DISABLE} Disable node"
    echo -e "    ${CYAN}7.${RESET} ${ICON_INSTALL} Update node"
    echo -e "    ${CYAN}8.${RESET} ${ICON_WALLLET} View private key"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Exit"
    draw_bottom_border
    echo -ne "${YELLOW}Enter your choice [0-8]: ${RESET}"
}

# ----------------------------
# Install Node
# ----------------------------
install_node() {
    cd
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${YELLOW}🟡 Node is already installed.${RESET}"
    else
        echo -e "${GREEN}🟢 Installing node...${RESET}"
        sudo apt update && sudo apt upgrade -y
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker

        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        git clone https://github.com/Uniswap/unichain-node
        cd unichain-node || { echo -e "${RED}❌ Failed to enter unichain-node directory.${RESET}"; return; }

        if [[ -f .env.sepolia ]]; then
            sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com|' .env.sepolia
            sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|' .env.sepolia
        else
            echo -e "${RED}❌ .env.sepolia file not found!${RESET}"
            return
        fi

        sudo docker-compose up -d

        echo -e "${GREEN}✅ Node has been successfully installed.${RESET}"
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}


update_node(){
    echo -e "${GREEN}🔄 Updating node...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    git -C ${HOMEDIR}/unichain-node/ pull
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Node has been update.${RESET}"
    echo
    read -p "Press Enter to return to the main menu..."
}

cat_private(){
    echo -e "${GREEN} 🔐 Private key${RESET}"
    HOMEDIR="$HOME"
    cat ${HOMEDIR}/unichain-node/geth-data/geth/nodekey; echo
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Restart Node
# ----------------------------
restart_node() {
    echo -e "${GREEN}🔄 Restarting node...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}✅ Node has been restarted.${RESET}"
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Check Node Status
# ----------------------------
check_node() {
    echo -e "${GREEN}✅ Checking node status...${RESET}"
    response=$(curl -s -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
      -H "Content-Type: application/json" http://localhost:8545)
    echo -e "${BLUE}Response:${RESET} $response"
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Check Logs of OP Node
# ----------------------------
check_logs_op_node() {
    echo -e "${GREEN}📄 Fetching logs for unichain-node-op-node-1...${RESET}"
    sudo docker logs unichain-node-op-node-1
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Check Logs of Execution Client
# ----------------------------
check_logs_execution_client() {
    echo -e "${GREEN}📄 Fetching logs for unichain-node-execution-client-1...${RESET}"
    sudo docker logs unichain-node-execution-client-1
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Disable Node
# ----------------------------
disable_node() {
    echo -e "${GREEN}⏹️ Disabling node...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    echo -e "${GREEN}✅ Node has been disabled.${RESET}"
    echo
    read -p "Press Enter to return to the main menu..."
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    show_menu
    read choice
    case $choice in
        1)
            install_node
            ;;
        2)
            restart_node
            ;;
        3)
            check_node
            ;;
        4)
            check_logs_op_node
            ;;
        5)
            check_logs_execution_client
            ;;
        6)
            disable_node
            ;;
        7)
            update_node
            ;;
        8)
            cat_private
            ;;
        0)
            echo -e "${GREEN}❌ Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option. Please try again.${RESET}"
            echo
            read -p "Press Enter to continue..."
            ;;
    esac
done



sudo curl -s https://raw.githubusercontent.com/antoninab4/uniswap/main/uniswap_node.sh -o uniswap_node.sh && sudo chmod +x uniswap_node.sh && sudo ./uniswap_node.sh
