require 'yaml'
require 'json'
require 'pry'
require 'pathname'
require_relative '../errors/invalid_file_pathname_error'
require_relative '../errors/invalid_file_format_error'

module FileConverter
  class YamlToJsonFileConverter
    YAML_FILE_REGEX = /\.yaml$|.yml$/
    INVALID_FILE_PATHNAME_ERROR_MESSAGE = 'Class must be initialized with a Pathname instance!'.freeze
    INVALID_FILE_FORMAT_ERROR_MESSAGE = 'The file to be converted must be an yaml!'.freeze

    def initialize(file_pathname)
      @file_pathname = file_pathname
    end

    def call
      raise InvalidFilePathnameError.new(INVALID_FILE_PATHNAME_ERROR_MESSAGE) unless @file_pathname.instance_of?(Pathname) 
      raise InvalidFileFormatError.new(INVALID_FILE_FORMAT_ERROR_MESSAGE) unless requested_file_yaml? && @file_pathname.file?

      File.open(json_file_path,'w') { |file| file.write(json_file_content)}
    end

    private
    private_constant :YAML_FILE_REGEX, :INVALID_FILE_PATHNAME_ERROR_MESSAGE, :INVALID_FILE_FORMAT_ERROR_MESSAGE 

    def requested_file_name
      @requested_file_name ||= @file_pathname.basename.to_s
    end

    def requested_file_yaml?
      requested_file_name.match?(YAML_FILE_REGEX)
    end

    def yaml_file
      @yaml_file ||= YAML.load_file(@file_pathname.to_s)
    end

    def json_file_name
      requested_file_name.sub(YAML_FILE_REGEX, '.json')
    end

    def json_file_path
      "#{@file_pathname.dirname}/#{json_file_name}"
    end

    def json_file_content
      JSON.pretty_generate(yaml_file.to_h)
    end
  end
end
