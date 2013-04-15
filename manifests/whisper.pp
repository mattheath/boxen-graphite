class graphite::whisper {
  include graphite::config

  repository { '/tmp/whisper':
    source    => 'graphite-project/whisper',
    provider  => 'git'
  }

  exec { 'install whisper':
    command => "cd ${graphite::config::builddir}/whisper && python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::libdir}",
    creates => "${graphite::config::basedir}/bin/whisper-info.py"
  }
}
