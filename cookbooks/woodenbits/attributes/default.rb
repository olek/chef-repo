# Machine profile ('personal' vs 'work')
default['woodenbits']['profile'] = 'personal'

# Catnap low-power sleep suite
default['woodenbits']['catnap']['idle'] = false
default['woodenbits']['catnap']['powerbtn'] = false

# TLP power management
default['woodenbits']['tlp']['enabled'] = false
default['woodenbits']['tlp']['mem_sleep_bat'] = 'deep'
default['woodenbits']['tlp']['battery_charge_thresholds'] = nil

# Hardware-specific quirks
default['woodenbits']['hardware']['expresscard_sata'] = false
