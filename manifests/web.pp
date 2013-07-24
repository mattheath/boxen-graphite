
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

  # Install mod_wsgi

  # First fix a missing link which breaks compilation
  # See here for more info: https://github.com/Homebrew/homebrew-apache#troubleshooting
  file { "/Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.8.xctoolchain":
    ensure => link,
    target => "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain",
    before => Homebrew::Formula['mod_wsgi'],
  }

  homebrew::formula { 'mod_wsgi':
    source => 'puppet:///modules/graphite/brews/mod_wsgi.rb',
  }

  package { 'boxen/brews/mod_wsgi':
    ensure => '3.4',
  }

  # A sprinkling of Django

  $django_version = '1.3'

  repository { "${boxen::config::cachedir}/django":
    source    => 'django/django',
    provider  => 'git'
  }

  exec { "ensure-django-version-${django_version}":
    command => "git fetch && git reset --hard ${django_version}",
    cwd     => "${boxen::config::cachedir}/django",
    unless  => "git describe --tags --exact-match `git rev-parse HEAD` | grep ${django_version}",
    require => Repository["${boxen::config::cachedir}/django"],
    notify  => Exec['install-django'],
  }

  exec { 'install-django':
    command   => "cd ${graphite::config::builddir}/django && python setup.py install",
    #creates   => "${graphite::config::bindir}/carbon-cache.py",
    require   => [
      Class['python'],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
  }

}
