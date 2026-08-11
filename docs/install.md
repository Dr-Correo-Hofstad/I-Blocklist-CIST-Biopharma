### iBlocklist Threat Intelligence Module Installation Guide

This document provides instructions for deploying the **CIST iBlocklist Threat Intelligence Module** on your cPanel/WHM server to establish an automated, 48-hour threat-feed synchronization routine. 

### System Prerequisites

Before running the automated installer, verify that your host server environment meets the following conditions: 

* **Root Access**: Elevated SSH privileges are mandatory for compilation, application directory creation, and AppConfig registration.
* **Perl Modules**: The backend sync engine relies on Net::IP for range calculation and IO::Uncompress::Gunzip for processing premium compressed .gz streams. Install them via your package manager or CPAN if missing: 

bash

cpan install Net::IP IO::Uncompress::Gunzip

Use code with caution.
* **API Credentials**: A valid Google Maps Geocoding API Key from the Google Cloud Console.

### Deployment Walkthrough

1. **Clone the Asset Package**
Transfer the repository assets onto your server via secure shell connection.
2. **Configure API Tokens**
Open src/iblocklist_worker.pl in an elevated text editor and append your Google Geocoding API key to the configuration line: 

perl

my $GOOGLE_API_K = 'YOUR_GOOGLE_MAPS_API_KEY';

Use code with caution.
3. **Authorize Installer Script Execution** 

bash

chmod +x install.sh

Use code with caution.
4. **Initialize Installation**
Run the master installer tool with root permissions: 

bash

sudo ./install.sh

Use code with caution.

### Post-Installation Audit

* **WHM Application Hub**: Log into Web Host Manager, navigate to the **Plugins** sidebar category, and ensure **CIST iBlocklist Core Analyser** is visible.
* **Automation Schedule**: Confirm that the 48-hour tracking cron loop has been safely added to the root system schedule: 

bash

crontab -l | grep iblocklist_worker.pl

Use code with caution.
