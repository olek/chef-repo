# Chef Workstation Repository (Chef Solo)

This repository is used to automate the configuration and package management of personal Ubuntu workstation environments via **Chef Solo** (running locally without a Chef Server).

## How System Hostname Affects Setup
Chef uses the system's **hostname** as the `node_name`. Certain recipes automatically customize behaviour based on this:
*   `sys-config` applies specific network, power, and trackball configurations for host `tenebrus`.
*   Usernames defaults to `opoplavsky` if host begins with `opoplavsky-`, otherwise defaults to `olek`.

---

## Bootstrapping a New Ubuntu Machine

Follow these steps to set up a brand new Ubuntu machine:

### Step 1: Clone this Repository
Clone this repository to the expected path in your home directory:
```bash
mkdir -p ~/git/my
git clone <this-repo-url> ~/git/my/chef-repo
```

### Step 2: Run the Initialization Script
Run the automated bootstrap script under `sudo` to install Cinc/Chef Client and configure `/etc/chef/solo.rb`:
```bash
cd ~/git/my/chef-repo
sudo ./chef-init
```

### Step 3: Run the Update Script
Run the configuration update using:
```bash
./chef-update
```

### Log Files
Chef Solo is configured via `/etc/chef/solo.rb` to write logs natively to `/var/log/chef/client.log`. You can monitor execution in real-time or troubleshoot errors by running:
```bash
tail -f /var/log/chef/client.log
```

> [!NOTE]
> **Console Colors in Chef 18**: 
> You may notice that console output logs are monochrome (no colorized status). 
> In Chef 18+, the client wraps the standard streams in a custom `IndentableOutputStream` class that does not implement the `.tty?` query. 
> Because of this, the underlying `tty-color` library detects the target stream as a non-interactive pipe and automatically disables all ANSI color escapes. 
> Attempting to force color via `--color` or `color true` is bypassed by this check.

---

## Workstation Scripts

The repository contains three helper scripts to manage your workstation setup.

> [!NOTE]
> All scripts internally embed or escalate via `sudo` (rather than allowing you to run them directly from a real root shell). This is intentional: the Chef recipes and bootstrap scripts must dynamically resolve the workstation owner by inspecting the `$SUDO_USER` environment variable. Running these scripts as the real root user (where `$SUDO_USER` is empty) will cause user-space configurations to fail.

*   **[chef-init](file:///home/olek/git/my/chef-repo/chef-init)**: Bootstraps the local environment by installing Cinc/Chef Client (if not present) and dynamically rendering `/etc/chef/solo.rb` from the repository template. (Automatically escalates via `sudo`).
*   **[chef-update](file:///home/olek/git/my/chef-repo/chef-update)**: Triggers `chef-solo` to apply your workstation recipes and synchronize configuration files. (Executes `chef-solo` under `sudo`).
*   **[chef-upgrade](file:///home/olek/git/my/chef-repo/chef-upgrade)**: Checks the currently installed version of Chef/Cinc Client. If it is below major version 18, it upgrades it to version 18. (Automatically escalates via `sudo`).

---

## Directory & Cookbook Structure

### Roles (`roles/`)
*   [workstation.rb](file:///home/olek/git/my/chef-repo/roles/workstation.rb) - Wraps `barebones` and installs user-packages, dev tools, and salesforce setup.
*   [barebones.rb](file:///home/olek/git/my/chef-repo/roles/barebones.rb) - Basic environment: repositories, configs, packages, and dotfiles.

### Cookbook Recipes (`cookbooks/woodenbits/recipes/`)
*   `sys-repos` - Standardizes Apt sources and software repositories.
*   `sys-packages` - Installs core system utilities (utilities, drivers).
*   `sys-config` - Automates system-level configuration files (udev, sysctl, systemd).
*   `user-init` - Creates users and sets permissions.
*   `user-config` - Manages dotfiles (bashrc, tmux, vim, gitconfig, ssh, etc.) and templates.
*   `user-packages` - Installs user-facing applications (browsers, editors).
*   `dev` & `dev-salesforce` - Configures programming languages, runtimes, and developer tooling.
*   `truecrypt` - Sets up TrueCrypt security and mounting configurations.

### Files and Templates (`cookbooks/woodenbits/`)
The assets used by recipes are structured by target destination under:
*   [templates/default/](file:///home/olek/git/my/chef-repo/cookbooks/woodenbits/templates/default) - Embedded Ruby (ERB) config templates:
    *   `system/` - System configuration templates (mirrors `/etc`, `/usr`).
    *   `home/` - User home configuration templates (mirrors `~/.config`, `~/bin`).
*   [files/default/](file:///home/olek/git/my/chef-repo/cookbooks/woodenbits/files/default) - Static binary or config files:
    *   `system/` - System binaries and installers.
    *   `home/` - Static user assets.
