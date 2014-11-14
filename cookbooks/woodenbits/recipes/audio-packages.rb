# Cookbook Name:: woodenbits
# Recipe:: sys-packages

# ========== audio

# command line music server/client player
package 'mpd'
package 'mpc'
package 'ncmpc'

# variety of music players / editors
package 'sonata'
package 'audacious'
package 'deadbeef'
package 'audacity'
package 'flac'

# music tagger and library organizer
package 'beets'
package 'beets-doc'

# support for omptagger
package 'libid3-dev'
package 'ruby-dev'

# to split one flac into multiple: cuebreakpoints file.cue | shnsplit -o flac file.flac
package 'cuetools'
package 'shntool'
