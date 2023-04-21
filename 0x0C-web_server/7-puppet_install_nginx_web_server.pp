# Install and configure Nginx
class nginx {
  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure => running,
    enable => true,
  }

  file { '/var/www/html/index.nginx-debian.html':
    ensure  => file,
    content => 'Hello World!',
    require => Package['nginx'],
  }

  file { '/etc/nginx/sites-available/default':
    ensure  => file,
    content => template('nginx/default.conf.erb'),
    notify  => Service['nginx'],
  }
}

# Configure default Nginx site
class nginx::default_site {
  file { '/var/www/html/error_404.html':
    ensure => file,
    content => 'Ceci n\'est pas une page',
    require => Class['nginx'],
  }

  nginx::resource::location { 'redirect_me':
    ensure    => present,
    location  => '/redirect_me',
    rewrite   => 'https://www.youtube.com/watch?v=QH2-TGUlwu4 permanent',
    require   => Class['nginx'],
  }
}

# Resource definition for Nginx location block
define nginx::resource::location (
  $ensure,
  $location,
  $rewrite = undef,
) {
  $config = {
    'location' => $location,
    'rewrite'  => $rewrite,
  }

  nginx::config { "location_${location}":
    ensure => $ensure,
    content => template('nginx/location.conf.erb'),
    config  => $config,
    require => Class['nginx'],
  }
}

# Template for default Nginx site
file { '/etc/nginx/sites-available/default':
  ensure => 'link',
  target => '/etc/nginx/sites-available/default.conf',
}

file { '/etc/nginx/sites-available/default.conf':
  ensure  => file,
  content => template('nginx/default.conf.erb'),
}

# Template for Nginx location block
file { '/etc/nginx/conf.d/location.conf':
  ensure => absent,
}

file { '/etc/nginx/location.conf':
  ensure  => file,
  content => template('nginx/location.conf.erb'),
}

# Set up Nginx to listen on port 80
class { 'nginx': }

# Restart Nginx if configuration changes
notify { 'nginx-restart':
  subscribe => [
    File['/var/www/html/index.nginx-debian.html'],
    File['/etc/nginx/sites-available/default'],
    File['/etc/nginx/sites-available/default.conf'],
    File['/etc/nginx/location.conf'],
  ],
  notify    => Service['nginx'],
}

