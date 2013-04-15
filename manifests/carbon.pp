class graphite::carbon {
  include graphite::config

  repository { '/tmp/carbon':
    source    => 'graphite-project/carbon',
    provider  => 'git'
  }
  
  exec { 'install carbon':
    command   => "cd ${graphite::config::builddir}/carbon && python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::libdir}",
    creates   => "${graphite::config::basedir}/bin/carbon-cache.py"
  }

  file { "${graphite::config::confdir}/storage-schemas.conf":
    content => template('graphite/storage-schemas.conf.erb')
  }

  file { "${graphite::config::confdir}/carbon.conf":
    content => template('graphite/carbon.conf.erb')
  }

  file { "${boxen::config::home}/bin/carbon-client.py":
    target  => "${graphite::config::bindir}/carbon-client.py",
    ensure  => link
  }

  file { "${boxen::config::home}/bin/carbon-relay.py":
    target  => "${graphite::config::bindir}/carbon-relay.py",
    ensure  => link
  }

  file { "${boxen::config::home}/bin/carbon-aggregator.py":
    target  => "${graphite::config::bindir}/carbon-aggregator.py",
    ensure  => link
  }

  file { "${boxen::config::home}/bin/carbon-cache.py":
    target  => "${graphite::config::bindir}/carbon-cache.py",
    ensure  => link
  }
}
