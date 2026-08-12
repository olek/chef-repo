# Flatten single-file directories in Chef templates and files

To avoid unnecessary folder nestiness, we flatten the directory structure of files or templates that are the sole contents of their parent directories into their filenames using a hyphen `-`.

## Context

When deploying configuration files via Chef, resources are typically placed in deep directories like `/etc/modprobe.d/wlan.conf` or `/etc/tlp.d/01-woodenbits.conf`. Under the standard Chef cookbook structure, templates or files would be mirrored under `templates/default/system/etc/modprobe.d/wlan.conf.erb`. This creates deep, nested directory structures containing only a single file.

## Decision

If a configuration file is the only file within its target subdirectory, we flatten the directory path in the cookbook's `files/` or `templates/` structure. The subfolder name and the filename are joined with a hyphen `-`, and the file is stored directly under the parent directory (e.g., `templates/default/system/etc/modprobe.d-wlan.conf.erb` and `templates/default/system/etc/tlp.d-01-woodenbits.conf.erb`).

## Consequences

* Reduces nested directory depth in the cookbook source tree, making navigation cleaner.
* Requires the Chef recipe to explicitly reference the flattened path in the `source` attribute of the `template` or `cookbook_file` resource.
