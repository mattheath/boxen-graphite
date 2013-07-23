class graphite::whisper {
  include boxen::config
  include graphite::config

  repository { "${boxen::config::cachedir}/whisper":
    source    => 'graphite-project/whisper',
    provider  => 'git'
  }

  exec { 'install whisper':
    command => "cd ${graphite::config::builddir}/whisper && python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::libdir}",
    creates => "${graphite::config::bindir}/whisper-info.py",
    require => [
      Repository["${boxen::config::cachedir}/whisper"],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
  }
}
