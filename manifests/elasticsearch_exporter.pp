# @summary This module manages prometheus elasticsearch_exporter
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param cnf_uri
#  The URI to obtain elasticsearch stats from
# @param cnf_timeout
#  Timeout for trying to get stats from elasticsearch URI
# @param download_extension
#  Extension for the release binary archive
# @param download_url
#  Complete URL corresponding to the where the release binary archive can be downloaded
# @param download_url_base
#  Base URL for the binary archive
# @param extra_groups
#  Extra groups to add the binary user to
# @param extra_options
#  Extra options added to the startup command
# @param group
#  Group under which the binary is running
# @param init_style
#  Service startup scripts style (e.g. rc, upstart or systemd)
# @param install_method
#  Installation method: url or package (only url is supported currently)
# @param manage_group
#  Whether to create a group for or rely on external code for that
# @param manage_service
#  Should puppet manage the service? (default true)
# @param manage_user
#  Whether to create user or rely on external code for that
# @param os
#  Operating system (linux is the only one supported)
# @param package_ensure
#  If package, then use this for package ensure default 'latest'
# @param package_name
#  The binary package name - not available yet
# @param purge_config_dir
#  Purge config files no longer generated by Puppet
# @param restart_on_change
#  Should puppet restart the service on configuration change? (default true)
# @param service_enable
#  Whether to enable the service from puppet (default true)
# @param service_ensure
#  State ensured for the service (default 'running')
# @param user
#  User which runs the service
# @param version
#  The binary release version
# @param use_kingpin
#  Since version 1.1.0, the elasticsearch exporter uses kingpin, thus
#  this param to define how we call the es.uri and es.timeout in the $options
#  https://github.com/justwatchcom/elasticsearch_exporter/blob/v1.1.0/CHANGELOG.md
class prometheus::elasticsearch_exporter (
  String $cnf_uri,
  String $cnf_timeout,
  String $download_extension,
  String $download_url_base,
  Array $extra_groups,
  String $group,
  String $package_ensure,
  String $package_name,
  String $user,
  String $version,
  Boolean $use_kingpin,
  Boolean $purge_config_dir               = true,
  Boolean $restart_on_change              = true,
  Boolean $service_enable                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  String $install_method                  = $prometheus::install_method,
  Boolean $manage_group                   = true,
  Boolean $manage_service                 = true,
  Boolean $manage_user                    = true,
  String[1] $os                           = $prometheus::os,
  String $extra_options                   = '',
  Optional[String] $download_url          = undef,
  String[1] $arch                         = $prometheus::real_arch,
  String $bin_dir                         = $prometheus::bin_dir,
  Boolean $export_scrape_job              = false,
  Stdlib::Port $scrape_port               = 9114,
  String[1] $scrape_job_name              = 'elasticsearch',
  Optional[Hash] $scrape_job_labels       = undef,
) inherits prometheus {

  #Please provide the download_url for versions < 0.9.0
  $real_download_url = pick($download_url,"${download_url_base}/download/v${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")

  $notify_service = $restart_on_change ? {
    true    => Service['elasticsearch_exporter'],
    default => undef,
  }

  $flag_prefix = $use_kingpin ? {
    true  => '--',
    false => '-',
  }

  $options = "${flag_prefix}es.uri=${cnf_uri} ${flag_prefix}es.timeout=${cnf_timeout} ${extra_options}"

  prometheus::daemon { 'elasticsearch_exporter':
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
    scrape_job_labels  => $scrape_job_labels,
  }
}
