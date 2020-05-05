#!/bin/sh

# Download LiteCart
if [ -x "$(which wget)" ] ; then
  wget -q "https://www.litecart.net/en/downloading?action=get&version=latest" -O litecart.zip
elif [ -x "$(which curl)" ]; then
  curl -o litecart.zip "https://www.litecart.net/en/downloading?action=get&version=latest"
else
  echo "Could not find either curl or wget, please install one." >&2
  exit;
fi

# Extract application directory
unzip litecart.zip
mv public_html/* ./

# Remove leftovers
rmdir public_html/
rm litecart.zip `basename "$0"`

echo "Extraction complete! Now open your web browser and go to your website to continue the installation."
