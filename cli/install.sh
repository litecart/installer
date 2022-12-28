#!/bin/bash

# Define variables
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
      echo "  This could be a meaningful help message in the future ;)"
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
if [[ -x "$(which wget)" ]]; then
  http_client="wget"
elif [[ -x "$(which curl)" ]]; then
  http_client="curl"
else
  echo "Could not find either curl or wget, please install one." >&2
  exit;
fi

clear

echo "##########################"
echo "##  LiteCart Installer  ##"
echo "##########################"

while [[ -z $app_dir ]]; do
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

if [[ -z $document_root ]]; then
  echo
  read -p "Document Root for '$app_dir' [$current_dir]: " document_root
  if [[ ! $document_root ]]; then
    document_root=$current_dir
  fi
fi

if [[ -z $db_server ]]; then
  echo
  read -p "MySQL Hostname [127.0.0.1]: " db_server
  if [[ ! $db_server ]]; then
    db_server="127.0.0.1"
  fi
fi

if [[ -z $db_username ]]; then
  echo
  read -p "MySQL Username [root]: " db_username
  if [[ ! $db_username ]]; then
    db_username="root"
  fi
fi

if [[ -z "$db_password" ]]; then
  echo
  read -p "MySQL Password for '$db_username': " db_password
fi

while [[ ! $db_database ]]; do
  echo
  read -p "MySQL Database: " db_database
done

if [[ ! mysql -h $db_server -u $db_username -p $db_password -e 'use mydbname']]; then
  while [[ ! $createdb =~ ^[yYnN]{1}$ ]]; do
    read -p "Database does not exist. Shall we create it? [y/n]: " createdb
  done
  if [[ $createdb =~ ^[yY]{1}$ ]]; then
    create database `$db_database` | mysql -h $db_server -u $db_username -p $db_password
  fi
fi

if [[ -z $db_prefix ]]; then
  echo
  read -p "MySQL Table Prefix [lc_]: " db_prefix
  if [[ ! $db_prefix ]]; then
    db_prefix="lc_"
  fi
fi

if [[ -z $db_collation ]]; then
  echo
  read -p "MySQL Collation [utf8_swedish_ci]: " db_collation
  if [[ ! $db_collation ]]; then
    db_collation="utf8_swedish_ci"
  fi
fi

if [[ $http_client == "wget" ]]; then
  current_timezone = "$(wget -qO- https://ipapi.co/timezone)"
elif [[ $http_client == "curl" ]]; then
  current_timezone = "$(curl -s https://ipapi.co/timezone)"
fi

if [[ -z $timezone ]]; then
  echo
  read -p "Store Timezone [$current_timezone]: " timezone
  if [[ ! $timezone ]]; then
    timezone=$current_timezone
  fi
fi

if [[ -z $admin_folder ]]; then
  echo
  read -p "Admin Folder Name [admin]: " admin_folder
  if [[ ! $admin_folder ]]; then
    admin_folder=admin
  fi
fi

if [[ -z $admin_username ]]; then
  echo
  read -p "Admin Username [admin]: " admin_username
  if [[ ! $admin_username ]]; then
    admin_username=admin
  fi
fi

while [[ -z $admin_password ]]; do
  echo
  read -p "Admin Password: " admin_password
done

if [[ -z $development_type ]]; then
  echo
  read -p "Development Type (standard|advanced) [standard]: " development_type
  if [[ ! $development_type ]]; then
    development_type=standard
  fi
fi

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
if [[ $http_client == "wget" ]]; then
  wget -qO litecart.zip "https://www.litecart.net/en/downloading?action=get&version=latest"
elif [[ $http_client == "curl" ]]; then
  curl -so litecart.zip "https://www.litecart.net/en/downloading?action=get&version=latest"
else
  echo "Could not find either curl or wget, please install one." >&2
fi

if [ ! -f litecart.zip ]; then
  echo "Download failed! Do we have write permissions?"
fi

# Extract application directory
echo "Extracting files..."
unzip litecart.zip "public_html/*"
mv public_html/* ./

# Remove leftovers
echo "Cleaning up..."
rmdir public_html/
rm litecart.zip

echo "Executing installation..."
php install/install.php \
  --document_root=\"$document_root\" \
  --db_server=$db_server \
  --db_database=$db_database \
  --db_username=$db_username \
  --db_password=\"$db_password\" \
  --db_prefix=$db_prefix \
  --db_collation=$db_collation \
  --timezone=\"$timezone\" \
  --admin_folder=$admin_folder \
  --admin_username=$admin_username \
  --admin_password=\"$admin_password\" \
  --development_type=$development_type

# Return to current directory
cd "$current_dir"
