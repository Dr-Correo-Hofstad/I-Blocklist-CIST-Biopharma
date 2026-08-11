### iBlocklist Threat Intelligence Module Uninstallation Guide

This document describes the instructions to cleanly remove the iBlocklist analytical scripts, unregister the WHM visual integration dashboard, and cancel all 48-hour automated synchronization tasks from the hosting node. 

### Automated Clean-up

To execute the standardized deletion protocol across your web server, use the master uninstaller script located at the root of the repository: 

1. **Navigate to the Repository Folder** 

bash

cd /path/to/I-Blocklist-CIST-Biopharma

Use code with caution.
2. **Authorize the Uninstaller** 

bash

chmod +x uninstall.sh

Use code with caution.
3. **Execute the Purge Script** 

bash

sudo ./uninstall.sh

Use code with caution.

### Manual Uninstallation Routine (Alternative)

If you have already deleted the local installation repository and cannot access uninstall.sh, perform these manual steps via your root command line interface: 

### 1. Remove the Automated 2-Day Task Loop

Access the system crontab file under elevated root control: 

bash

crontab -e

Use code with caution.

Find and completely erase the entry that maps the 48-hour synchronization interval: 

text

0 0 */2 * * /usr/local/cpanel/whostmgr/docroot/cgi/whm_iblocklist_geoip/iblocklist_worker.pl >/dev/null 2>&1

Use code with caution.

Save your changes and close the editor to commit the scheduling modification. 

### 2. De-register the Plugin Application from WHM

Run the cPanel AppConfig utility to remove the dashboard registration signature: 

bash

/usr/local/cpanel/bin/unregister_appconfig whm_iblocklist_geoip

Use code with caution.

### 3. Clear Assets from the Server File System

Delete the binary directory path to free up allocations: 

bash

rm -rf /usr/local/cpanel/whostmgr/docroot/cgi/whm_iblocklist_geoip

Use code with caution.
