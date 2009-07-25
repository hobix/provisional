require 'provisional/scm/git'
require 'net/http'
require 'net/https'
require 'heroku'

module Provisional
  module SCM
    class Heroku < Provisional::SCM::Git
      def checkin
        begin
          credentials = File.open(File.join(ENV['HOME'],'.heroku','credentials'),'r').readlines.map{|l| l.chomp}
        rescue
          raise RuntimeError, "Please log into Heroku using the command line tool before using Provisional."
        end
        raise RuntimeError, "Heroku credentials not in expected format" unless credentials.length == 2
        begin
          repo = super
          heroku = ::Heroku::Client.new(credentials[0], credentials[1])
          heroku.create(@options['name'])
          repo.add_remote('heroku', "git@heroku.com:#{@options['name']}.git")
          repo.push(repo.remote('heroku'))
        rescue
          raise RuntimeError, "Repository created locally, but not pushed to Heroku due to exception: #{$!}"
        end
      end
    end
  end
end
