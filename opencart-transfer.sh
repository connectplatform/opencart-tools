#!/bin/bash

echo "Opencart transfer script v0.1 (c)Sonoratek LLC"

# Check for OpenCart config file
if [[ -f config.php ]]; then
    # Extract site URL and OpenCart version
    siteURL=$(grep 'HTTP_SERVER' config.php | cut -d "'" -f 4)
    version=$(grep 'VERSION' index.php | cut -d "'" -f 2)

    echo "Website $siteURL found, Opencart $version."
    echo "Please select a backup option:"
    echo "1. Make a full backup of this website"
    echo "2. Make a backup without product data"
    echo "3. Exit the script"

    read -p "Enter your choice (1, 2, or 3): " choice

    case $choice in
        1|2)
            # Extract database credentials
            db_name=$(awk -F"'" '/DB_DATABASE/{print $4}' config.php)
            db_user=$(awk -F"'" '/DB_USERNAME/{print $4}' config.php)
            db_password=$(awk -F"'" '/DB_PASSWORD/{print $4}' config.php)
            db_host=$(awk -F"'" '/DB_HOSTNAME/{print $4}' config.php)

            # Dump the database
            mysqldump -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" > db_backup.sql
            echo "Processing database...DONE"

            # Generate backup filename
            domain=$(echo $siteURL | awk -F"/" '{print $3}' | cut -d "." -f 1)
            random_hex=$(openssl rand -hex 3)
            backup_filename="${domain}${random_hex}.tar.gz"

            # Compress files
            if [ "$choice" -eq 1 ]; then
                tar --exclude="$backup_filename" -czf "$backup_filename" .
            else
                tar --exclude="$backup_filename" --exclude="image/catalog/*" -czf "$backup_filename" .
            fi
            echo "Compressing files...DONE"
            echo "Backup filename is: $backup_filename"

            echo "This script can also migrate this website to a new server."
            echo "Simply run the script on the destination server and enter the filename above."
            ;;
        3)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option selected."
            ;;
    esac
else
    echo "No Opencart found. If you are migrating from another server, please make sure this script is in a public root directory, where index.php of Opencart resides."
    echo "Please select your option:"
    echo "1. Download backup and restore on this server"
    echo "2. Exit script"

    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            read -p "Enter site domain name (without https://): " site_domain
            read -p "Enter backup filename (as shown during backup): " backup_filename

            echo "Backup found, downloading...DONE"
            wget "https://${site_domain}/${backup_filename}"

            echo "Extracting files...DONE"
            tar -xzvf "$backup_filename"

            # Extract database credentials
            db_name=$(awk -F"'" '/DB_DATABASE/{print $4}' config.php)
            db_user=$(awk -F"'" '/DB_USERNAME/{print $4}' config.php)
            db_password=$(awk -F"'" '/DB_PASSWORD/{print $4}' config.php)
            db_host=$(awk -F"'" '/DB_HOSTNAME/{print $4}' config.php)

            # Create and import database
            mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS $db_name;"
            mysql -u root -p $db_name < db_backup.sql

            echo "Creating database...DONE"
            echo "Importing SQL data...DONE"

            # Remove backup files
            rm "$backup_filename" db_backup.sql

            echo "Removing backup files...DONE"
            echo "Success! $site_domain has been restored successfully. You may set up your webserver for this vhost."
            ;;
        2)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option selected."
            ;;
    esac
fi
