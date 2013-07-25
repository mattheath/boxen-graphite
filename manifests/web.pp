
class graphite::web {

  include apache
  include apache::mod_wsgi
  include nginx
  include cairo
  include cairo::pycairo
  include homebrew

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
    command   => "cd ${graphite::config::builddir}/graphite-web && /opt/boxen/homebrew/bin/python setup.py install --prefix=${graphite::config::basedir} --install-lib=${graphite::config::webdir} --install-scripts=${graphite::config::bindir}",
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
    require   => Class['python']
  }

  # Install django-tagging

  $django_tagging_file_name = 'django-tagging-0.3.1.tar.gz'
  $django_tagging_source    = "https://django-tagging.googlecode.com/files/${django_tagging_file_name}"

  exec { 'cache-django-tagging':
    command => "curl -k -O ${django_tagging_source} && tar -xzf ${django_tagging_file_name}",
    cwd     => $boxen::config::cachedir,
    creates => "${boxen::config::cachedir}/django-tagging-0.3.1",
  }

  exec { 'install-django-tagging':
    command   => "cd ${boxen::config::cachedir}/django-tagging-0.3.1 && /opt/boxen/homebrew/bin/python setup.py install",
    creates   => "${homebrew::config::installdir}/lib/python2.7/site-packages/django_tagging-0.3.1-py2.7.egg-info",
    require   => [
      Class['python'],
      Exec['cache-django-tagging'],
    ]
  }

  # Add a local settings file to remove some log errors

  file { "${graphite::config::webdir}/graphite/local_settings.py":
    source  => 'puppet:///modules/graphite/local_settings.py',
    require => Exec['install-graphite-web'],
    notify  => Service['org.apache.httpd'],
  }

  # Setup database

  file { "${graphite::config::webdir}/graphite/initial_data.json":
    content => template('graphite/db-dump.json.erb'),
    require => Exec['install-graphite-web'],
  }

  exec { 'install-graphite-database':
    provider => shell,
    command  => 'export LANG=es_ES.UTF-8 && export LC_ALL=es_ES.UTF-8 && /opt/boxen/homebrew/bin/python manage.py syncdb --noinput',
    cwd      => "${graphite::config::webdir}/graphite/",
    unless   => "[ -f ${graphite::config::basedir}/storage/graphite.db ] && sqlite3 ${graphite::config::basedir}/storage/graphite.db \"SELECT name FROM sqlite_master WHERE name='auth_user'\" | grep 'auth_user'",
    require  => [
      File["${graphite::config::webdir}/graphite/initial_data.json"],
      Exec['install-django'],
      Exec['install-django-tagging'],
    ]
  }

  # graphite.wsgi

  file { "${graphite::config::confdir}/graphite.wsgi":
    content => template('graphite/graphite.wsgi.erb'),
    require => Exec['install-graphite-web'],
  }

  # Apache VHost

  file { "${apache::config::sitesdir}/graphite.conf":
    content => template('graphite/apache-vhost.conf.erb'),
    owner   => 'root',
    group   => 'wheel',
    notify  => Service['org.apache.httpd'],
  }

  # Nginx proxy

  file { "${nginx::config::sitesdir}/graphite.conf":
    content => template('graphite/nginx.conf.erb'),
    notify  => Service['dev.nginx'],
  }

}
