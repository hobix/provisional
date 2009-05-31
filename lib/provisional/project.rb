require 'active_support'
require 'provisional'
require 'uri'
require 'yaml'

module Provisional
  class Project
    attr_reader :options
    
    def initialize(options)
      @options = HashWithIndifferentAccess.new
      if options[:config]
        begin
          @options = @options.merge(YAML.load_file(options[:config]))
        rescue
          raise ArgumentError, "could not be loaded or parsed: #{options[:config]}"
        end
      end
      @options = @options.merge(options.reject{|key, value| value.nil?})

      @options[:scm] ||= 'git'
      @options[:template] ||= 'viget'

      begin
        template_is_url = [URI::HTTP, URI::HTTPS].include?(URI.parse(@options['template']).class)
      rescue URI::InvalidURIError
        template_is_url = false
      end

      unless template_is_url
        if File.exist?(File.expand_path(@options['template']))
          @options['template_path'] = File.expand_path(@options['template'])
        else
          @options['template_path'] = File.expand_path(File.join(File.dirname(__FILE__),'templates',"#{@options['template']}.rb"))
        end
        raise ArgumentError, "is not valid: #{@options['template']}" unless File.exist?(@options['template_path'])
      else
        @options['template_path'] = @options['template']
      end

      raise ArgumentError, "name must be specified" unless @options['name']
      raise ArgumentError, "already exists: #{@options['name']}" if File.exist?(@options['name'])
      raise ArgumentError, "already exists: #{@options['name']}.repo" if @options['scm'] == 'svn' && File.exist?("#{@options['name']}.repo")

      begin
        require "provisional/scm/#{@options['scm']}"
      rescue MissingSourceFile
        raise ArgumentError, "is not supported: #{@options['scm']}"
      end

      scm_class = "Provisional::SCM::#{@options['scm'].classify}".constantize
      scm = scm_class.new(@options)
      scm.init
      scm.generate_rails
      scm.checkin
    end

  end
end
