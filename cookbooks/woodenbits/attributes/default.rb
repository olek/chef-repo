# Machine profile ('personal' vs 'work')
default['woodenbits']['profile'] = 'personal'

# Catnap low-power sleep suite
default['woodenbits']['catnap']['idle'] = false
default['woodenbits']['catnap']['powerbtn'] = false

# TLP power management
default['woodenbits']['tlp']['enabled'] = false
default['woodenbits']['tlp']['mem_sleep_ac'] = 's2idle'
default['woodenbits']['tlp']['mem_sleep_bat'] = 'deep'
default['woodenbits']['tlp']['battery_charge_thresholds'] = nil
# Drivers whose PCI(e) devices are excluded from Runtime PM (TLP
# RUNTIME_PM_DRIVER_DENYLIST). nil keeps the previous behaviour (empty list);
# set per-node, e.g. 'thunderbolt', to stop a device sinking into a D3cold
# state it can't resume from.
default['woodenbits']['tlp']['runtime_pm_driver_denylist'] = nil

# Hardware-specific quirks
default['woodenbits']['hardware']['expresscard_sata'] = false
