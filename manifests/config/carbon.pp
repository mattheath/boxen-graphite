# Configuration for Carbon

class graphite::config::carbon {

  include graphite::config

  $executable = "${graphite::config::bindir}/carbon-cache.py"

  $line_receiver_port   = '12003'
  $udp_receiver_port    = '12003'
  $pickle_receiver_port = '12004'
  $cache_query_port     = '17002'

}