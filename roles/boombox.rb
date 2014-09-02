name 'boombox'
description 'Setup for music player computer.'

run_list(
  'role[barebones]',
  'recipe[woodenbits::audio-packages]'
)
