# The Events Calendar Pro Auto-Update Script
Bash Script which automatically updates the events calendar pro wordpress plugin. For example on multisite, automatic updates are not working with a regular license this script enables you to automatically update the plugin by scheduling a cron job. Just paste in your License Key and the path to your wp-installation.

The script checks if a new version is available, downloads the zip file and installs it via wp-cli. It should also work on most shared hosting providers, it only requires python with json installed (my hosting provider had this preinstalled).
