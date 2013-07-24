class graphite::config {
  include boxen::config

  $builddir = $boxen::config::cachedir
  $basedir  = "${boxen::config::home}/graphite"
  $libdir   = "${basedir}/lib"
  $confdir  = "${basedir}/conf"
  $bindir   = "${basedir}/bin"
  $logdir   = "${boxen::config::logdir}/graphite"

}
