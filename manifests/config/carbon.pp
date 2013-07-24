# Configuration for Carbon

class graphite::config::carbon {

  $line_receiver_port   = '12003'
  $udp_receiver_port    = '12003'
  $pickle_receiver_port = '12004'
  $cache_query_port     = '17002'

}