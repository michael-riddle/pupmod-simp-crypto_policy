# frozen_string_literal: true

require 'beaker-rspec'
require 'tmpdir'
require 'yaml'
require 'simp/beaker_helpers'
include Simp::BeakerHelpers

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

RSpec.configure do |c|
  # ensure that environment OS is ready on each host
  fix_errata_on hosts

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install modules and dependencies from spec/fixtures/modules
    copy_fixture_modules_to(hosts)
    begin
      server = only_host_with_role(hosts, 'server')
    rescue ArgumentError => e
      server = only_host_with_role(hosts, 'default')
    end

    # Generate and install PKI certificates on each SUT
    Dir.mktmpdir do |cert_dir|
      run_fake_pki_ca_on(server, hosts, cert_dir)
      hosts.each { |sut| copy_pki_to(sut, cert_dir, '/etc/pki/simp-testing') }
    end

    # add PKI keys
    copy_keydist_to(server)
  rescue StandardError, ScriptError => e
    raise e unless ENV['PRY']

    # rubocop:disable Lint/Debugger
    require 'pry'
    binding.pry # rubocop:disable Lint/Debugger
    # rubocop:enable Lint/Debugger
  end
end
