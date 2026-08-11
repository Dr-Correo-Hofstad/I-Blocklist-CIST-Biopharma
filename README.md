### CIST iBlocklist Threat Intelligence Module

An automated threat intelligence engine and WHM (Web Host Manager) integration wrapper designed to ingest premium, authenticated iBlocklist feeds, parse compressed P2P/IP block data, and cross-reference network connections for active perimeter defense. 

### Functional Architecture

The module runs persistently as a background daemon, executing an end-to-end synchronization cycle every 48 hours to ensure zero-day protection across our managed hosting nodes. 

text

[ 48-Hour Interval ] ──> [ Authenticated Feed Ingestion (.gz) ] ──> [ Memory Stream Decompression ]
                                                                                │
[ Targeted Email Dispatch ] <── [ Fast People Search Link ] <── [ Reverse Google Geocoding ]
Use code with caution.

### Configured Subscription Feeds

This module integrates with five premium threat tracking endpoints mapped directly to specialized malicious classification profiles: 

* **Feed 1 (dufcxgnbjsdwmwctgfuj):** IP ranges of people who we have found to be sharing child pornography in the p2p community.
* **Feed 2 (pbqcylkejciyhmwttify):** Addresses that have been indentified distributing malware during the past 30 days 
* **Feed 3 (czvaehmjpsnwwttrdoyl):** Exploitation sources, script vectors, and command controllers.
* **Feed 4 (ghlzqtqxnzctvvajwwag):** IP addresses related to current web server hack and exploit attempts that have been logged
* **Feed 5 (llvtlsjyoyiczbkjsxpf):** Known malicious spyware and adware IP Address ranges.
* **Feed 6 (xpbqleszmajjesnzddhv):** Contains known Hackers and such people in it.

### Repository Layout

text

├── docs/
│   ├── install.md           # Deployment operational procedures
│   └── uninstall.md         # Removal instructions and clean-up parameters
├── src/                     # Core application source
│   ├── iblocklist_worker.pl # Decompression parser, log scanner, and notification logic
│   ├── index.cgi            # WHM graphical administrative index page
│   └── whm_iblocklist.conf  # cPanel AppConfig integration schema
├── LICENSE                  # Software authorization profile
├── install.sh               # Root initialization engine script
├── uninstall.sh             # Structural purge script
└── README.md                # This system map file

Use code with caution.

### Setup & Initialization

### 1. Insert Authentication Credentials

Before initiating deployment, open src/iblocklist_worker.pl in an elevated shell text editor and append your authorized Google Maps Geocoding API token: 

perl

my $GOOGLE_API_K = 'YOUR_GOOGLE_MAPS_API_KEY';

Use code with caution.

### 2. Execute the Automated Deployment

Run the primary infrastructure setup automation tool as root. This utility provisions secure directories, applies restrictive file ownership settings (root:root), updates the cPanel AppConfig table, and maps the 2-day automation daemon: 

bash

chmod +x install.sh
sudo ./install.sh

Use code with caution.

### System Maintenance and Purge

To completely detach the iBlocklist analytical modules, clear out backend application registers, and unschedule the 48-hour checking loop, run the master cleanup utility script: 

bash

chmod +x uninstall.sh
sudo ./uninstall.sh

Use code with caution.
