#!/bin/sh

# Download LiteCart
wget https://github.com/litecart/litecart/archive/master.zip

# Extract application directory
unzip master.zip "litecart-master/public_html/*"
mv litecart-master/public_html/* ./

# Remove leftovers
rmdir litecart-master/public_html litecart-master
rm master.zip install.sh

echo Done
