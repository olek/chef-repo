# Cookbook Name:: woodenbits
# Recipe:: audio-packages

# command line music server/client player

package 'mpd'
package 'mpc'
package 'ncmpc'

# variety of music players / editors
#package 'sonata'
package 'audacious'
# not available in 21.10 and does not work with backport
#package 'deadbeef'
package 'audacity'
package 'flac'
package 'asterisk-core-sounds-en-wav'

# support for omptagger
package 'libid3-dev'
package 'ruby-dev'

#package 'radiotray'

unless node[:hostname].start_with?('opoplavsky-')
  # music tagger and library organizer
  package 'beets'
  package 'beets-doc'

  package 'flacon' # .flac and .ape splitting

  # to split one flac into multiple: cuebreakpoints file.cue | shnsplit -o flac file.flac
  package 'cuetools'
  package 'shntool'
end
