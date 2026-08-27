name 'workstation'
description 'Wraps all required recipes for my typical workstation setup.'

run_list(
  'role[barebones]',
  'recipe[woodenbits::catnap]',
  'recipe[woodenbits::user-packages]',
  'recipe[woodenbits::dev]',
  'recipe[woodenbits::dev-salesforce]'
)
