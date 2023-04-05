#!/bin/bash

WP_PATH="/PATH/TO/WORDPRESS"
LICENSE_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Get latest plugin versions from api
curl -LJs -o "plugin_latest.json" "https://pue.tri.be/api/plugins/v2/plugins/latest"

# Define the search substring
substring="events calendar pro"

# Use curl to retrieve the JSON data from the URL and extract the version and download URL
version_url=$(python -c "import json; data = json.load(open('plugin_latest.json')); matching_plugins = [elem for elem in data['plugins'] if '$substring'.lower() in elem['plugin_name'].lower()]; print('{0}:{1}'.format(matching_plugins[0]['plugin_version'], matching_plugins[0]['plugin_download_url']))")

# Check if a matching plugin was found
if [[ "$version_url" == "" ]]; then
  echo "Plugin not found."
  exit 1
fi

# Extract the version and download URL from the version_url string
IFS=':' read -r new_version download_url <<< "$version_url"

# Get the version number of the currently installed plugin
installed_version=$(wp plugin get events-calendar-pro --field=version --path="$WP_PATH")

echo "Installed Version: $installed_version"
echo "New Version: $new_version"

# Compare the version numbers
version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

if version_gt "$new_version" "$installed_version"; then
  
  echo "There is a newer version available"
  echo "Updating the events-calendar-pro from $installed_version to $new_version ..."

  echo "Checking for updates for the-events-calendar ..." # new version is often needed for the pro plugin
  wp plugin update "the-events-calendar" --path="$WP_PATH"
  
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