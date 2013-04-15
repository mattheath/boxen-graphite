class graphite::config {
  include boxen::config

  $builddir = '/tmp'
  $basedir = "${boxen::config::home}/graphite"
  $libdir = "${basedir}/lib"
  $confdir = "${basedir}/conf"
  $bindir = "${basedir}/bin"
}
