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

    wget -O - https://raw.githubusercontent.com/litecart/installer/master/cli/install.sh | bash

  **Or curl**

    curl -s https://raw.githubusercontent.com/litecart/installer/master/cli/install.sh | bash

2. Follow the instructions on the screen.

-----------------------------------------------------------------------

Note: You can predefine values passed to the install script:

    ./install.sh --app_dir=... \
                 --document_root=... \
                 --db_server=... \
                 --db_user=... \
                 --db_password=... \
                 --db_database=... \
                 --db_prefix=... \
                 --timezone=... \
                 --admin_folder=... \
                 --admin_user=... \
                 --admin_password=...
