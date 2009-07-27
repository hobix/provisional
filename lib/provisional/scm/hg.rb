require 'fileutils'
require 'provisional/rails_application'

module Provisional
  module SCM
    class Hg
      def initialize(options)
        @options = options
      end

      def init
        rescuing_exceptions do
          FileUtils.mkdir_p @options['name']
          Dir.chdir @options['name']
          @options['path'] = Dir.getwd
          system("hg init")
        end
      end

      def generate_rails
        rescuing_exceptions do
          Provisional::RailsApplication.new(@options['path'], @options['template_path'])
        end
      end

      def checkin
        rescuing_exceptions do
          system("hg add .")
          system("hg commit -m 'Initial commit by Provisional'")
        end
      end

      def provision
        self.init
        self.generate_rails
        self.checkin
      end
    end
  end
end
