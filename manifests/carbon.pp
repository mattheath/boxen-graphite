class graphite::carbon {

  include python
  include boxen::config
  include graphite::config
  include graphite::config::carbon
  include homebrew::config

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
  }

  exec { 'install-twisted':
    command   => "cd ${graphite::config::builddir}/twisted && python setup.py install",
    creates   => "${homebrew::config::installdir}/lib/python2.7/site-packages/Twisted-${twisted_version}-py2.7-macosx-10.8-x86_64.egg",
    require   => [
      Class['python'],
      Exec["ensure-twisted-version-${twisted_version}"],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
  }

  # Set up config

  file { "${graphite::config::confdir}/storage-schemas.conf":
    content => template('graphite/storage-schemas.conf.erb')
  }

  file { "${graphite::config::confdir}/carbon.conf":
    content => template('graphite/carbon.conf.erb')
  }

}
