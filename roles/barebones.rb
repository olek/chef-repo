name 'barebones'
description 'Basic setup of comfortable system.'

recipes %w(sys-repos sys-config sys-packages user-init user-config).map { |name| "woodenbits::#{name}" }
