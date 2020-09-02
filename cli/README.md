        __    _ __       ______           __
       / /   (_) /____  / ____/___ ______/ /_
      / /   / / __/ _ \/ /   / __ `/ ___/ __/
     / /___/ / /_/  __/ /___/ /_/ / /  / /_
    /_____/_/\__/\___/\____/\__,_/_/   \__/
                          www.litecart.net

# Instructions

To install the latest version of LiteCart from a terminal window, do the following:

1. Download and execute the installer:

  **Using wget**

    bash -c "$(wget -O- https://raw.githubusercontent.com/litecart/installer/master/cli/install.sh)"

  **Or curl**

    bash -c "$(curl https://raw.githubusercontent.com/litecart/installer/master/cli/install.sh)"

2. Follow the instructions on the screen.

-----------------------------------------------------------------------

Note: You can predefine values passed to the install script:

    ./install.sh --app_dir=... \
                 --document_root=/var/www/litecart/public_html \
                 --db_server=localhost \
                 --db_user=johndoe \
                 --db_password=mycatsname \
                 --db_database=mylitecartdb \
                 --db_prefix=lc_ \
                 --timezone=Europe/London \
                 --admin_folder=admin \
                 --admin_user=admin \
                 --admin_password=mydogsname \
                 --development_type=standard
