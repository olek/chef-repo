name 'workstation'
description 'Wraps all required recipes for my typical workstation setup.'

recipes %w(sys-config sys-packages user-init user-config rbenv).map { |name| "woodenbits::#{name}" }
