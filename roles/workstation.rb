name 'workstation'
description 'Wraps all required recipes for my typical workstation setup.'

run_list(
  'role[barebones]',
  'recipe[woodenbits::user-packages]',
  'recipe[woodenbits::dev]'
)
