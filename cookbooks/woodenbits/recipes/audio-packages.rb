# Cookbook Name:: woodenbits
# Recipe:: audio-packages

# command line music server/client player

package 'mpd'
package 'mpc'
package 'ncmpc'

# variety of music players / editors
#package 'sonata'
package 'audacious'
package 'deadbeef'
package 'audacity'
package 'flac'
package 'flacon' # .flac and .ape splitting
package 'asterisk-core-sounds-en-wav'

# music tagger and library organizer
package 'beets'
package 'beets-doc'

# support for omptagger
package 'libid3-dev'
package 'ruby-dev'

# to split one flac into multiple: cuebreakpoints file.cue | shnsplit -o flac file.flac
package 'cuetools'
package 'shntool'

#package 'radiotray'
