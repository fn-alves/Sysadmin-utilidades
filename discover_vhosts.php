#!/usr/bin/env php -n
<?php
function apache_vhosts($binary='/usr/sbin/apache2ctl')
{
  $command = " -S 2>&1 | grep 'port ' | awk {'print $2,$4'} | sort -u -t' ' -k2,2 | grep -v 'localhost'";
  $vhosts = shell_exec(sprintf("%s %s", $binary, $command));
  $vhosts = explode("\n", trim($vhosts));
  $results = array();
  foreach($vhosts as $vhost)
  {
    $x = explode(' ', $vhost, 2);
    $new_entry['{#SERVERNAME}'] = $x[1];
    $new_entry['{#SERVERPORT}'] = $x[0];
    $results['data'][] = $new_entry;
  }
  return $results;
}
function nginx_vhosts() {
  $vhosts = shell_exec("grep -Pro '\bserver_name\s*\K[^;]*' /etc/nginx | sed 's/:/ /' | awk {'print $1,$2'} | grep -v 'localhost'");
  $vhosts = explode(PHP_EOL, trim($vhosts));
  $results = array();
  foreach($vhosts as $vh) {
    $x = explode(' ', $vh, 2);
    $domain = $x[1];
    $file = $x[0];
    # Grab ports from file
    $ports = shell_exec( sprintf("grep -Pro '\blisten\s*\K[^;]*' %s | awk {'print $1'} | grep -o '[0-9]*' | sort | uniq", $file));
    $ports = explode(PHP_EOL, trim($ports), 2);
    foreach($ports as $port)
    {
      $result = array();
      $result['{#SERVERNAME}'] = $domain;
      $result['{#SERVERPORT}'] = $port;
      $results['data'][] = $result;
    }
  }
  return $results;
}
function main() {
  if (file_exists('/etc/nginx')) {
    echo json_encode( nginx_vhosts() );
  }
  elseif (file_exists('/usr/sbin/apache2ctl'))
  {
    echo json_encode( apache_vhosts() );
  } elseif (file_exists('/usr/sbin/apachectl')) {
    echo json_encode( apache_vhosts('/usr/sbin/apachectl') );
  }
}
main();