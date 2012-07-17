name 'workstation'
description 'Wraps all required recipes for my typical workstation setup.'

recipes %w(sys-config sys-packages user-init user-config).map { |name| "woodenbits::#{name}" }
