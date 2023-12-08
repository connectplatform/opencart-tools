# OpenCart Transfer Script

This script, created by Sonoratek LLC, is designed for efficient migration and backup of OpenCart-powered websites. It can create a full backup of your site, including or excluding product data, and assist in migrating an OpenCart site to a new server.

## Features

- **Full Backup**: Create a complete backup of your OpenCart site, including the database and all files.
- **Partial Backup**: Create a backup excluding product images, which is useful for creating a lighter copy of large websites for development purposes.
- **Automated Restoration**: Facilitates the restoration of an OpenCart site on a new server using a previously created backup file.

## Prerequisites

- The script should be run on the server where the OpenCart site is hosted.
- Ensure that `mysqldump` is available for database backup.
- `wget` should be installed for downloading backups in the restoration process.
- MySQL root or equivalent privileges for creating and importing databases during restoration.

## Usage

### Backup

1. Place the script in the root directory of your OpenCart website.
2. Run the script:

   ```bash
   ./opencart-transfer.sh
   ```
3. Follow the on-screen prompts to select the backup option:
   - '1' for a full backup.
   - '2' for a backup excluding product data.
4. The script will process the database and files, then provide a backup filename like domain43ba53.tar.gz.

### Restoration

1. Place the script in the root directory of the destination server for your OpenCart site.
2. Run the script and choose the option to download and restore the backup.
3. Provide the site domain name and backup filename when prompted.

The script will handle the rest, including database creation and data import.

## Notes

- Backup filenames are generated with the domain name and a random hex value for uniqueness and security.
- Ensure that the MySQL user has sufficient privileges to perform all database operations.

## License
This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details.