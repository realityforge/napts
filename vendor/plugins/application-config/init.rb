require 'ostruct'
require 'yaml'
::ApplicationConfig = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/config.yml"))

#
# This plugin allows you to access application specific configuration from "#{RAILS_ROOT}/config/config.yml".
# Assuming that the following is defined in the config file
#
# proxy_config:
#   host: proxy.cs.latrobe.edu.au
#   port: 8080
#
# Then you could access the config in the following manner. Note that it checks whether the proxy_config
# method is defined first just in case you elided the section from config file
#
# if Module.constants.include?("ApplicationConfig") && ApplicationConfig.respond_to?(:proxy_config)
#    return Net::HTTP::Proxy(ApplicationConfig.proxy_config['host'], ApplicationConfig.proxy_config['port'])
# else
#    return Net::HTTP
# end
