class graphite::carbon {

  include python
  include boxen::config
  include graphite::config
  include graphite::config::carbon
  include homebrew::config

  # Install Carbon

  $carbon_version = '0.9.11-pre1'

  repository { "${boxen::config::cachedir}/carbon":
    source    => 'graphite-project/carbon',
    provider  => 'git'
  }

  exec { "ensure-carbon-version-${carbon_version}":
    command => "git fetch && git reset --hard ${carbon_version}",
    cwd     => "${boxen::config::cachedir}/carbon",
    unless  => "git describe --tags --exact-match `git rev-parse HEAD` | grep ${carbon_version}",
    require => Repository["${boxen::config::cachedir}/carbon"],
    notify  => Exec['install-carbon'],
  }

  exec { 'install-carbon':
    command   => "cd ${graphite::config::builddir}/carbon && python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::libdir} --install-scripts=${graphite::config::bindir}",
    creates   => "${graphite::config::bindir}/carbon-cache.py",
    require   => [
      Class['python'],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
    notify    => Service['dev.carbon'],
  }

  # Install Twisted, yeah sorry this is global

  $twisted_version = '11.1.0'
  $twisted_tag     = "twisted-${twisted_version}"

  repository { "${boxen::config::cachedir}/twisted":
    source   => 'twisted/twisted',
    provider => 'git'
  }

  exec { "ensure-twisted-version-${twisted_version}":
    command => "git fetch && git reset --hard ${twisted_tag}",
    cwd     => "${boxen::config::cachedir}/twisted",
    unless  => "git describe --tags --exact-match `git rev-parse HEAD` | grep ${twisted_tag}",
    require => Repository["${boxen::config::cachedir}/twisted"],
    notify  => Exec['install-twisted'],
  }

  exec { 'install-twisted':
    command   => "cd ${graphite::config::builddir}/twisted && python setup.py install",
    creates   => "${homebrew::config::installdir}/lib/python2.7/site-packages/Twisted-${twisted_version}-py2.7-macosx-10.8-x86_64.egg",
    require   => [
      Class['python'],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
    notify    => Service['dev.carbon'],
  }

  # Set up config

  file { "${graphite::config::confdir}/storage-schemas.conf":
    content => template('graphite/storage-schemas.conf.erb'),
    notify  => Service['dev.carbon'],
  }

  file { "${graphite::config::confdir}/carbon.conf":
    content => template('graphite/carbon.conf.erb'),
    notify  => Service['dev.carbon'],
  }


  file { '/Library/LaunchDaemons/dev.carbon.plist':
    content => template('graphite/dev.carbon.plist.erb'),
    group   => 'wheel',
    owner   => 'root',
    require => [
      Exec['install-carbon'],
      Exec['install-twisted'],
    ],
    notify  => Service['dev.carbon'],
  }

  service { 'dev.carbon':
    ensure  => running,
  }


}
