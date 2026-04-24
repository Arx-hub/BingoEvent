# Linux Crontab Deployment (No Docker / No Service Files)

Since you want to avoid Docker and host-level service files, we will use the **Linux Crontab** method. This allows the API to start automatically in the background whenever the server boots up, without you needing to run any manual commands after the initial setup.

## User Review Required

> [!IMPORTANT]
> This method assumes you have already copied your `publish` folder contents to `/var/www/bingo-api/` on your server using SFTP or SCP.

> [!TIP]
> This is a set-and-forget method. Once configured, you can close PuTTY and the API will keep running. If you ever reboot your server, the API will start up by itself.

## Proposed Changes

### Configuration: The @reboot Directive

We will use the `@reboot` directive in your user's crontab. This is a special command that Linux runs every time the system starts up.

**Steps to implement:**
1.  Log in via PuTTY.
2.  Open your crontab editor:
    ```bash
    crontab -e
    ```
    *(If it asks which editor to use, choose `nano` by typing `1` and pressing Enter).*
3.  Scroll to the very bottom and add this exact line:
    ```bash
    @reboot cd /var/www/bingo-api && dotnet API_folder.dll --urls "http://localhost:5000" > /var/www/bingo-api/api.log 2>&1
    ```
4.  Save and exit (`Ctrl + O`, `Enter`, then `Ctrl + X`).

### Management Commands

Since you won't have a "service" to stop/start, here is how you manage the API in the future:

- **To start it manually right now (in the background):**
  ```bash
  cd /var/www/bingo-api && nohup dotnet API_folder.dll --urls "http://localhost:5000" > api.log 2>&1 &
  ```
- **To see if it is running:**
  ```bash
  ps aux | grep dotnet
  ```
- **To stop it:**
  ```bash
  pkill dotnet
  ```

## Open Questions

- **Do you already have .NET Runtime installed on your Linux server?** (If not, run `sudo apt-get install -y dotnet-runtime-6.0` or the version matching your project).
- **Do you already have the /var/www/bingo-api directory created?** (`sudo mkdir -p /var/www/bingo-api && sudo chown $USER:$USER /var/www/bingo-api`).

## Verification Plan

### Manual Verification
1. Reboot the server (or simulate a crash).
2. Verify the API is still accessible via `curl http://localhost:5000/health` (or `/api/bingo/health` depending on your routes).
3. Check the logs at `/var/www/bingo-api/api.log` to ensure the process started correctly.
