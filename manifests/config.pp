# General configuration for Graphite

class graphite::config {

  include boxen::config

  $builddir = $boxen::config::cachedir
  $basedir  = "${boxen::config::home}/graphite"
  $bindir   = "${basedir}/bin"
  $confdir  = "${basedir}/conf"
  $libdir   = "${basedir}/lib"
  $logdir   = "${boxen::config::logdir}/graphite"
  $webdir   = "${basedir}/webapp"


}
