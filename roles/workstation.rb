name 'workstation'
description 'Wraps all required recipes for my typical workstation setup.'

recipes %w(sys-repos sys-config sys-packages truecrypt user-init user-config rvm modcloth).map { |name| "woodenbits::#{name}" }
