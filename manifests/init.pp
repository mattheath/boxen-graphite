class graphite {

  include boxen::config
  include graphite::carbon
  include graphite::config::carbon
  include graphite::whisper
  include graphite::web

  # Create directory structure
  file { [
    $graphite::config::basedir,
    $graphite::config::libdir,
    $graphite::config::confdir,
    $graphite::config::bindir,
    $graphite::config::logdir,
    $graphite::config::webdir,
  ]:
    ensure  => directory,
  }

  # Link normal boxen config to graphites config location
  file { "${boxen::config::configdir}/graphite":
    ensure  => link,
    target  => $graphite::config::confdir,
    require => File[$boxen::config::configdir],
  }

  # Set up graphite env vars and paths
  file { "${boxen::config::envdir}/graphite.sh":
    content => template('graphite/env.sh.erb')
  }

}
