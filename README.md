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

### Step 2: Run the Bootstrap Script
Run the automated bootstrap script under `sudo` to install Cinc/Chef Client, and configure `/etc/chef/solo.rb`:
```bash
cd ~/git/my/chef-repo
sudo ./bootstrap.sh
```

### Step 3: Execute Chef Solo
Execute the configuration run using:
```bash
./run-chef.sh
```

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
