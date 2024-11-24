# WordPress Cleanup Script

This Bash script scans all WordPress installations under a specified directory, identifies unauthorized files using **WP-CLI**'s `core verify-checksums`, and removes them. It also temporarily changes ownership for the script to run, restores the original ownership and permissions, and ensures file and directory security.

## Features

- Automatically identifies all WordPress installations by locating `wp-config.php` files.
- Uses WP-CLI to verify the integrity of WordPress core files.
- Removes suspicious files flagged by WP-CLI.
- Temporarily changes ownership for operations and restores the original owner.
- Ensures secure permissions for files and directories after execution.

## Requirements

### Install WP-CLI

Ensure that WP-CLI is installed on your server before running this script. To install WP-CLI:

```bash
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
```

Verify the installation with:

```bash
wp --info
```

### Edit the Script

Before running the script, open it with a text editor to set your username:

```bash
nano clean_wp_files.sh
```

Locate the line:

```bash
TEMP_OWNER="yourname:nogroup"
```

Replace `yourname` with your username (e.g., `matteo`). Save and exit the editor.

## Usage

### Clone the Repository

Clone the repository to your server:

```bash
git clone https://github.com/your-repo/wordpress-cleanup.git
```

Navigate to the directory:

```bash
cd wordpress-cleanup
```

### Make the Script Executable

Ensure the script is executable:

```bash
chmod +x clean_wp_files.sh
```

### Run the Script

Run the script with `sudo` to ensure it can manage file permissions:

```bash
sudo ./clean_wp_files.sh
```

## Scheduled Execution (Optional)

To automate this script, you can schedule it to run nightly using a cron job.

1. Open the crontab editor:

   ```bash
   sudo crontab -e
   ```

2. Add the following line to schedule the script to run every night at 4 AM:

   ```bash
   0 4 * * * /path/to/clean_wp_files.sh >> /var/log/clean_wp_files.log 2>&1
   ```

3. Save and exit. The script will now run automatically at 4 AM every day.

## Security Note

- Ensure backups of your WordPress installations before running the script.
- Double-check the temporary ownership configuration in the script.

## Troubleshooting

If you encounter any issues:
1. Verify that WP-CLI is correctly installed and accessible.
2. Check that you have permissions to run the script on the specified directory.
3. Ensure the username and group specified in the script match your system configuration.

## Contributing

Feel free to contribute by submitting pull requests or reporting issues in the [Issues section](https://github.com/your-repo/wordpress-cleanup/issues).