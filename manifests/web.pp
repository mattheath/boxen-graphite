
class graphite::web {

  include apache
  include apache::mod_wsgi
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
    creates   => "${graphite::config::webdir}/graphite/manage.py",
    require   => [
      Class['python'],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
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
    creates   => "/opt/boxen/homebrew/share/python/django-admin.py",
    require   => [
      Class['python'],
      File[$graphite::config::bindir],
      File[$graphite::config::libdir],
    ],
  }

  # Add a local settings file to remove some log errors

  file { "${graphite::config::webdir}/graphite/local_settings.py":
    source => 'puppet:///modules/graphite/local_settings.py',
  }

}
