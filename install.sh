#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Run as root."
  exit 1
fi

SRC_DIR="./src"
PLUGIN_DIR="/usr/local/cpanel/whostmgr/docroot/cgi/whm_iblocklist_geoip"
CONF_FILE="whm_iblocklist.conf"
WORKER_SCRIPT="iblocklist_worker.pl"

echo "=== Initializing iBlocklist Tracking Engine Setup ==="

mkdir -p "$PLUGIN_DIR"
cp -r "$SRC_DIR"/* "$PLUGIN_DIR/"

chown -R root:root "$PLUGIN_DIR"
chmod 755 "$PLUGIN_DIR"
if [ -f "$PLUGIN_DIR/$WORKER_SCRIPT" ]; then chmod 700 "$PLUGIN_DIR/$WORKER_SCRIPT"; fi

# Register with WHM ecosystem AppConfig
if [ -f "$PLUGIN_DIR/$CONF_FILE" ]; then
    /usr/local/cpanel/bin/register_appconfig "$PLUGIN_DIR/$CONF_FILE"
fi

# AUTOMATION DEAMON TIMING: Setup 2-Day Chron interval
# Expressed as: Run at midnight every 2 days (*/2)
CRON_JOB="0 0 */2 * * $PLUGIN_DIR/$WORKER_SCRIPT >/dev/null 2>&1"
( crontab -l 2>/dev/null | grep -F "$WORKER_SCRIPT" ) \
    || ( crontab -l 2>/dev/null; echo "$CRON_JOB" ) | crontab -

echo "=== Engine Ready: Configured to report every 2 days ==="
