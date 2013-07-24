
class graphite::web {

  include apache
  include cairo
  include cairo::pycairo

  # Install Graphite Web

  $web_version = '0.9.11-pre1'

  repository { "${boxen::config::cachedir}/graphite-web":
    source    => 'graphite-project/graphite-web',
    provider  => 'git'
  }

  exec { "ensure-graphite-web-version-${web_version}":
    command => "git fetch && git reset --hard ${web_version}",
    cwd     => "${boxen::config::cachedir}/graphite-web",
    unless  => "git describe --tags --exact-match `git rev-parse HEAD` | grep ${web_version}",
    require => Repository["${boxen::config::cachedir}/graphite-web"],
    notify  => Exec['install-graphite-web'],
  }

  exec { 'install-graphite-web':
    command   => "cd ${graphite::config::builddir}/graphite-web && python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::webdir} --install-scripts=${graphite::config::bindir}",
    #creates   => "${graphite::config::bindir}/carbon-cache.py",
    require   => [
      Class['python'],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
  }

}