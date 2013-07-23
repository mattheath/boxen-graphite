class graphite {
  include graphite::carbon
  include graphite::whisper

  # Create directory structure
  file { [
    $graphite::config::basedir,
    $graphite::config::libdir,
    $graphite::config::confdir,
    $graphite::config::bindir,
  ]:
    ensure  => directory,
  }

}
