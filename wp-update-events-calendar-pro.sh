#!/bin/bash

WP_PATH="/PATH/TO/WORDPRESS"
LICENSE_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Get latest plugin versions from api
curl -LJs -o "plugin_latest.json" "https://pue.tri.be/api/plugins/v2/plugins/latest?plugin=events-calendar-pro"

# Get the version number of the latest plugin
new_version=$(python -c "import json; data = json.load(open('plugin_latest.json')); print([elem for elem in data['plugins'] if elem['plugin_name'] == 'Events Calendar PRO'][0]['plugin_version'])")

# Get the version number of the currently installed plugin
installed_version=$(wp plugin get events-calendar-pro --field=version --path="$WP_PATH")

# Compare the version numbers
version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

if version_gt "$new_version" "$installed_version"; then
  
  echo "There is a newer version available"
  echo "Updating the events-calendar-pro from $installed_version to $new_version ..."

  echo "Checking for updates for the-events-calendar ..." # new version is often needed for the pro plugin
  wp plugin update "the-events-calendar" --path="$WP_PATH"
  
  download_url=$(python -c "import json; data = json.load(open('plugin_latest.json')); print([elem for elem in data['plugins'] if elem['plugin_name'] == 'Events Calendar PRO'][0]['plugin_download_url'])")
  filename="events-calendar-pro.${new_version}.zip"

  curl -LJs -o "$filename" "${download_url}&key=${LICENSE_KEY}"
  
  # Install downloaded zip
  wp plugin install "$filename" --force --path="$WP_PATH"

  # Remove zip file
  rm "$filename"
else

  echo "You are already up to date"

fi

# Remove json file
rm plugin_latest.json