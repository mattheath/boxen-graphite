class graphite::carbon {

  include python
  include boxen::config
  include graphite::config

  # Install Carbon

  repository { "${boxen::config::cachedir}/carbon":
    source    => 'graphite-project/carbon',
    provider  => 'git'
  }

  exec { 'install-carbon':
    command   => "cd ${graphite::config::builddir}/carbon && python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::libdir} --install-scripts=${graphite::config::bindir}",
    creates   => "${graphite::config::bindir}/carbon-cache.py",
    require   => [
      Class['python'],
      Repository["${boxen::config::cachedir}/carbon"],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
  }

  file { "${graphite::config::confdir}/storage-schemas.conf":
    content => template('graphite/storage-schemas.conf.erb')
  }

  file { "${graphite::config::confdir}/carbon.conf":
    content => template('graphite/carbon.conf.erb')
  }

}
