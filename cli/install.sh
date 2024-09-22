#!/bin/bash

# Define variables
current_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Capture named arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app_dir*)
      app_dir="${1#*=}"
      ;;
    --document_root*)
      document_root="${1#*=}"
      ;;
    --db_server*)
      db_server="${1#*=}"
      ;;
    --db_database*)
      db_database="${1#*=}"
      ;;
    --db_username*)
      db_username="${1#*=}"
      ;;
    --db_password*)
      db_password="${1#*=}"
      ;;
    --db_prefix*)
      db_prefix="${1#*=}"
      ;;
    --db_collation*)
      db_collation="${1#*=}"
      ;;
    --timezone*)
      timezone="${1#*=}"
      ;;
    --country*)
      country="${1#*=}"
      ;;
    --admin_folder*)
      admin_folder="${1#*=}"
      ;;
    --admin_username*)
      admin_username="${1#*=}"
      ;;
    --admin_password*)
      admin_password="${1#*=}"
      ;;
    --development_type*)
      development_type="${1#*=}"
      ;;
    --help|-h)
      echo
      echo LiteCart CLI Installer
      echo "Copyright (c) $(date +"%Y") LiteCart AB"
      echo  "https://www.litecart.net/"
      echo  "Usage: install.sh [options]"
      echo
      echo  "Options:"
      echo  "  --app_dir            Set application directory"
      echo  "  --document_root      Set document root"
      echo  "  --db_server          Set database hostname (Default: 127.0.0.1)"
      echo  "  --db_username        Set database username"
      echo  "  --db_password        Set database user password"
      echo  "  --db_database        Set database name"
      echo  "  --db_table_prefix    Set database table prefix (Default: lc_)."
      echo  "  --db_collation       Set database collation (Default: utf8_swedish_ci)"
      echo  "  --timezone           Set timezone e.g. Europe/London"
      echo  "  --country            Set country e.g. US"
      echo  "  --admin_folder       Set admin folder name (Default: admin)"
      echo  "  --username           Set admin username"
      echo  "  --password           Set admin user password"
      echo  "  --development_type   Set development type 'standard' or 'advanced' (Default: standard)"
      echo
      echo "Example:"
      echo "  install.sh --app_dir=/var/www/html --db_username=litecart --db_password=secret"
      echo
      exit
      ;;
    *)
      >&2 printf "Error: Invalid argument ($1)\n"
      exit
      ;;
  esac
  shift
done

# Check dependencies
if [[ -x $(which curl) ]]; then
  http_client="curl"
elif [[ -x $(which wget) ]]; then
  http_client="wget"
else
  echo "Could not find either curl or wget, please install one." >&2
  exit;
fi

# Welcome
clear

echo "##########################"
echo "##  LiteCart Installer  ##"
echo "##########################"

# Set application path
while [ ! "$app_dir" ]; do
  echo
  read -p "Installation folder [$current_dir]: " app_dir
  if [[ ! $app_dir ]]; then
    app_dir=$current_dir
  fi

  if [[ ! -d $app_dir ]]; then
    while [[ ! $confirm =~ ^[yYnN]{1}$ ]]; do
      read -p "The directory \"$app_dir\" does not exist. Should it be created? [y/n]: " confirm
    done

    if [[ $confirm =~ ^[Yy]$ ]]; then
      mkdir "$app_dir"
    else
      app_dir=
      confirm=
    fi
  fi
done

# Define document root
if [ ! "$document_root" ]; then
  echo
  read -p "Document Root for '$app_dir' [$app_dir]: " document_root
  if [[ ! $document_root ]]; then
    document_root=$app_dir
  fi
fi

# Detect MySQL binary
if [[ -x $(which mariadb 2>/dev/null) ]]; then
  db_daemon="mariadb"
elif [[ -x $(which mysql 2>/dev/null) ]]; then
  db_daemon="mysql"
else
  db_daemon=
fi

# Set MySQL hostname
if [ ! $db_server ]; then
  echo
  read -p "MySQL Hostname [127.0.0.1]: " db_server
  if [[ ! $db_server ]]; then
    db_server="127.0.0.1"
  fi
fi

# Set MySQL username and password
while [ ! $db_username ]; do
  echo
  read -p "MySQL Username [root]: " db_username
  if [ ! $db_username ]; then
    db_username="root"
  fi

  echo
  read -sp "MySQL Password for '$db_username': " db_password

  # Test MySQL credentials
  if [ $db_daemon ]; then
    echo
    echo
    echo "Testing MySQL credentials..."
    if [[ $($db_daemon --host="$db_server" --user="$db_username" --password="$db_password" --execute="SHOW DATABASES;") ]]; then
      echo " [OK] Connection success"
    else
      db_username=
    fi
  fi
done

# Set MySQL database
while [ ! $db_database ]; do

  if [ $db_daemon ]; then
    echo
    $db_daemon --host="$db_server" --user="$db_username" --password="$db_password" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME NOT LIKE 'INFORMATION_SCHEMA'"
  fi

  echo
  read -p "MySQL Database: " db_database

  # Test MySQL database
  if [ $db_daemon ] && [ ! $db_database ]; then
    if [[ ! $($db_daemon --host="$db_server" --user="$db_username" --password="$db_password" -e "SHOW DATABASES LIKE '$db_database';") ]]; then
      echo " [Error] No such database"
      db_database=
    fi
  fi
done

# Set MySQL table prefix
if [ ! $db_prefix ]; then
  echo
  read -p "MySQL Table Prefix [lc_]: " db_prefix
  if [ ! $db_prefix ]; then
    db_prefix="lc_"
  fi
fi

# Set MySQL default collation
if [ ! $db_collation ]; then
  echo
  read -p "MySQL Collation [utf8mb4_swedish_ci]: " db_collation
  if [ ! $db_collation ]; then
    db_collation="utf8mb4_swedish_ci"
  fi
fi

# Get country via IP API
if [ $http_client == "curl" ]; then
  current_country=$(curl -s https://ipapi.co/country)
elif [ $http_client == "wget" ]; then
  current_country=$(wget -qO- https://ipapi.co/country)
fi

# Set store country
while [[ ! $country =~ ^[A-Z]{2}$ ]]; do
  echo
  read -p "Store Country Code [$current_country]: " country

  if [[ ! $country ]]; then
    country=$current_country
  fi
done

# Get timezone via IP API
if [ $http_client == "curl" ]; then
  current_timezone=$(curl -s https://ipapi.co/timezone)
elif [ $http_client == "wget" ]; then
  current_timezone=$(wget -qO- https://ipapi.co/timezone)
fi

# Set store timezone
if [ ! $timezone ]; then
  echo
  read -p "Store Timezone [$current_timezone]: " timezone
  if [ ! $timezone ]; then
    timezone=$current_timezone
  fi
fi

# Set backend folder name
if [ ! $admin_folder ]; then
  echo
  read -p "Admin Folder Name [admin]: " admin_folder
  if [[ ! $admin_folder ]]; then
    admin_folder=admin
  fi
fi

# Set backend username
if [ ! $admin_username ]; then
  echo
  read -p "Admin Username [admin]: " admin_username
  if [ ! $admin_username ]; then
    admin_username=admin
  fi
fi

# Set backend password
while [ ! $admin_password ]; do
  echo
  read -sp "Desired password for user '$admin_username': " admin_password
  echo
done

# Set development mode
if [ ! $development_type ]; then
  echo
  read -p "Development Type (standard|advanced) [standard]: " development_type
  if [ ! $development_type ]; then
    development_type=standard
  fi
fi

# Show summary
clear

echo
echo "###############"
echo "##  CONFIRM  ##"
echo "###############"
echo
echo "Installation folder: $app_dir"
echo "Document Root: $document_root"
echo
echo "MySQL Hostname: $db_server"
echo "MySQL Username: $db_username"
echo "MySQL Database: $db_database"
echo "MySQL Table Prefix: $db_prefix"
echo "MySQL Collation: $db_collation"
echo
echo "Store Country: $country"
echo "Time Zone: $timezone"
echo
echo "Admin Folder: $admin_folder"
echo "Admin User: $admin_username"
echo "Admin Password: ********"
echo
echo "Development Type: $development_type"
echo

while [[ ! $confirm =~ ^[yYnN]{1}$ ]]; do
  read -p "Is this information correct? [y/n]: " confirm
done

if [[ $confirm =~ ^[Nn]$ ]]; then
  echo "Mission aborted!"
  exit
fi

# Temporary move to installation the folder
cd "$app_dir"

# Download LiteCart
echo "Downloading latest version of LiteCart..."
if [ $http_client == "curl" ]; then
  curl -so litecart.zip "https://www.litecart.net/en/downloading?action=get&version=latest"
elif [ $http_client == "wget" ]; then
  wget -qO litecart.zip "https://www.litecart.net/en/downloading?action=get&version=latest"
fi

if [ ! -f litecart.zip ]; then
  echo "Download failed! Do we have write permissions?"
fi

# Extract application directory
echo "Extracting files..."
unzip litecart.zip "public_html/*"
mv -f public_html/* ./

# Remove leftovers
echo "Cleaning up..."
rm -rf public_html/
rm -f litecart.zip

cd "install/"

echo "Executing installation..."
php install.php \
  --document_root="$document_root" \
  --db_server=$db_server \
  --db_database=$db_database \
  --db_username=$db_username \
  --db_password="$db_password" \
  --db_prefix=$db_prefix \
  --db_collation=$db_collation \
  --country=$country \
  --timezone="$timezone" \
  --admin_folder=$admin_folder \
  --admin_username=$admin_username \
  --admin_password="$admin_password" \
  --development_type=$development_type

# Return to current directory
cd "$current_dir"
