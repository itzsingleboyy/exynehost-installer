#!/bin/bash

# ExyneHost Fix Tool - Made by Single
# India's Leading High-Performance Game Cloud

# Root check
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root!"
    exit 1
fi

# Banner
echo "###############################################"
echo "#       Welcome to the ExyneHost Fix Tool      #"
echo "#  India's Leading High-Performance Game Cloud #"
echo "#   Optimized for Minecraft & AI Workloads!    #"
echo "#       Visit: https://discord.gg/exynehost    #"
echo "###############################################"
sleep 3

# Main Menu
echo "What issue are you facing?"
echo "1) Panel"
echo "2) Wings"
echo "3) Database"
echo "4) Themes"
read -p "Enter your choice: " issue_type

### PANEL ###
if [[ "$issue_type" == "1" ]]; then
    echo "Panel Issue Type?"
    echo "1) Panel-install"
    echo "2) SSL"
    echo "3) env"
    echo "4) Upgrade"
    echo "5) Build Panel Assets"
    echo "6) Panel Reset (without data loss)"
    read -p "Enter your choice: " panel_issue

    case $panel_issue in
        1)
            bash <(curl -s https://pterodactyl-installer.se)
            ;;
        2)
            read -p "Enter FQDN (e.g., panel.example.com): " fqdn
            apt update
            apt install -y certbot python3-certbot-nginx
            certbot certonly --nginx -d "$fqdn"
            ;;
        3)
            echo "⚠️ Too risky to automate env edit. Exiting."
            exit 1
            ;;
        4)
            cd /var/www/pterodactyl || exit
            php artisan down
            curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
            chmod -R 755 storage/* bootstrap/cache
            composer install --no-dev --optimize-autoloader
            php artisan view:clear
            php artisan config:clear
            php artisan migrate --seed --force
            chown -R www-data:www-data /var/www/pterodactyl/*
            php artisan queue:restart
            php artisan up
            ;;
        5)
            curl -sL https://deb.nodesource.com/setup_16.x | bash -
            apt install -y nodejs
            npm i -g yarn
            cd /var/www/pterodactyl || exit
            yarn install --network-timeout 600000
            apt update && apt upgrade -y
            ;;
        6)
            curl -o panel-reset.sh https://raw.githubusercontent.com/Alfha240/Petrpdactyl-fix/main/panel-reset.sh
            chmod +x panel-reset.sh
            bash panel-reset.sh
            ;;
        *)
            echo "❌ Invalid choice."
            ;;
    esac

### WINGS ###
elif [[ "$issue_type" == "2" ]]; then
    echo "Wings fixes coming soon."

### DATABASE ###
elif [[ "$issue_type" == "3" ]]; then
    echo "1) Create Database for Node"
    read -p "Enter your choice: " db_issue

    if [[ "$db_issue" == "1" ]]; then
        read -p "Enter DB Username [default: lorduser]: " db_user
        db_user=${db_user:-lorduser}
        read -p "Enter DB Password [default: lordpass]: " db_pass
        db_pass=${db_pass:-lordpass}

        curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash
        apt update
        apt -y install mariadb-server

        mysql -e "CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_pass';"
        mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%' WITH GRANT OPTION;"
        mysql -e "FLUSH PRIVILEGES;"

        echo "Edit /etc/mysql/my.cnf and set bind-address=0.0.0.0"
        echo "Then run: systemctl enable --now mariadb"
        read -p "Press Enter when ready..."
    else
        echo "❌ Invalid choice."
    fi

### THEMES ###
elif [[ "$issue_type" == "4" ]]; then
    echo "1) Standalone (Coming Soon)"
    echo "2) Blueprint"
    echo "3) Free Theme Install"
    read -p "Enter your choice: " theme_choice

    case $theme_choice in
        1)
            echo "Standalone theme installation coming soon."
            ;;
        2)
            echo "⚠️ Blueprint replaces core files. Backup recommended."
            read -p "Backup /var/www/pterodactyl? (Y/N): " backup_choice
            if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
                tar -czvf /var/www/pterodactyl/backup_$(date +%F).tar.gz /var/www/pterodactyl
            fi

            echo "1) Install Blueprint"
            echo "2) Install Nebula"
            read -p "Enter your choice: " blueprint_choice

            if [[ "$blueprint_choice" == "1" ]]; then
                bash <(curl -s https://raw.githubusercontent.com/Alfha240/Pterodactyl-Fix-Toolkit/main/Blueprint-install.sh)
            elif [[ "$blueprint_choice" == "2" ]]; then
                read -p "Enter panel path [default: /var/www/pterodactyl]: " panel_path
                panel_path=${panel_path:-/var/www/pterodactyl}
                wget -O "$panel_path/nebula.blueprint" "https://storage.xitewebservices.cloud/nebula.blueprint"
                cd "$panel_path" || { echo "Panel path not found!"; exit 1; }
                blueprint -install nebula
            else
                echo "❌ Invalid choice."
            fi
            ;;
        3)
            echo "Free Themes Available:"
            echo "1) Nook-theme"
            echo "2) Ice Minecraft-theme"
            echo "3) Minecraft Purple-theme"
            read -p "Enter your choice: " free_theme_choice

            case $free_theme_choice in
                1)
                    curl -O https://raw.githubusercontent.com/Alfha240/Petrpdactyl-fix/main/nook-theme.sh
                    chmod +x nook-theme.sh
                    bash nook-theme.sh
                    ;;
                2)
                    bash <(curl -s https://raw.githubusercontent.com/Angelillo15/IceMinecraftTheme/main/install.sh)
                    ;;
                3)
                    bash <(curl -s https://raw.githubusercontent.com/Angelillo15/MinecraftPurpleTheme/main/install.sh)
                    ;;
                *)
                    echo "❌ Invalid theme choice."
                    ;;
            esac
            ;;
        *)
            echo "❌ Invalid theme choice."
            ;;
    esac
else
    echo "❌ Invalid main menu choice."
fi
