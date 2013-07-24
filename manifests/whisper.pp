class graphite::whisper {

  include boxen::config
  include graphite::config
  include python

  $whisper_version = '0.9.11-pre1'

  repository { "${boxen::config::cachedir}/whisper":
    source    => 'graphite-project/whisper',
    provider  => 'git'
  }

  exec { "ensure-whisper-version-${whisper_version}":
    command => "git fetch && git reset --hard ${whisper_version}",
    cwd     => "${boxen::config::cachedir}/whisper",
    unless  => "git describe --tags --exact-match `git rev-parse HEAD` | grep ${whisper_version}",
    require => Repository["${boxen::config::cachedir}/whisper"],
    notify  => Exec['install-whisper'],
  }

  exec { 'install-whisper':
    command => "cd ${graphite::config::builddir}/whisper && python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::libdir} --install-scripts=${graphite::config::bindir}",
    creates => "${graphite::config::bindir}/whisper-info.py",
    require => [
      Class['python'],
      Repository["${boxen::config::cachedir}/whisper"],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
  }

  # Link the whisper library to the same directory as the scripts
  file { "${graphite::config::bindir}/whisper.py":
    target  => "${graphite::config::libdir}/whisper.py",
    ensure  => link,
    require => Exec['install-whisper'],
  }
}
