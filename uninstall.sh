#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Run as root."
  exit 1
fi

PLUGIN_DIR="/usr/local/cpanel/whostmgr/docroot/cgi/whm_iblocklist_geoip"
WORKER_SCRIPT="iblocklist_worker.pl"

echo "=== Removing iBlocklist Tracking Engine ==="

/usr/local/cpanel/bin/unregister_appconfig whm_iblocklist_geoip 2>/dev/null
crontab -l 2>/dev/null | grep -v "$WORKER_SCRIPT" | crontab -
rm -rf "$PLUGIN_DIR"

echo "=== Uninstallation Complete ==="
