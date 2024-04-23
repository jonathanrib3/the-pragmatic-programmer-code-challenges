require_relative '../../spec_helper'
require_relative '../../../src/lib/file_converter'
require_relative '../../../src/errors/invalid_file_pathname_error'
require_relative '../../../src/errors/invalid_file_format_error'

RSpec.describe FileConverter::YamlToJsonFileConverter do
  subject(:yaml_file_converter) { described_class.new(file_pathname) }
  
  context 'when initializing the converter with an argument that is not a Pathname instance' do
    let(:file_pathname) { '/some/path/to/a/file.yml' }

    it 'raises a InvalidFilePathnameError' do
      expect{yaml_file_converter.call}.to raise_error(InvalidFilePathnameError, 'Class must be initialized with a Pathname instance!')
    end
  end
  
  context 'when initializing the converter with an argument that is a Pathname instance' do
    context 'and the path is not from a file' do
      let(:file_pathname) { Pathname.new('/some/path/to/a/') }
      
      it 'raises a InvalidFileFormatError' do
        expect{yaml_file_converter.call}.to raise_error(InvalidFileFormatError, 'The file to be converted must be an yaml!')
      end
    end

    context 'and the path is from a file that is not yaml' do
      let(:file_pathname) { Pathname.new('/some/path/to/a/notyamlfile.json') }
      
      it 'raises a InvalidFileFormatError' do
        expect{yaml_file_converter.call}.to raise_error(InvalidFileFormatError, 'The file to be converted must be an yaml!')
      end
    end

    context 'and the path is from a file that is yaml' do
      let(:file_pathname) { Pathname.new("#{__dir__}/../../fixtures/file.yml") }
      let(:converted_file_path) { "#{file_pathname.dirname.to_s}/file.json" }
      let(:expected_content) { "{\n  \"hello\": {\n    \"world\": [\n      \"venus\",\n      \"earth\",\n      \"mercury\"\n    ]\n  }\n}" }

      it 'creates a new json file' do
        yaml_file_converter.call

        expect(File.exist?(converted_file_path)).to be_truthy
        FileUtils.rm(converted_file_path)
      end

      it 'converts the requested yaml file to a new json file with the same content from the requested file' do
        yaml_file_converter.call

        expect(File.read(converted_file_path)).to eq(expected_content)
        FileUtils.rm(converted_file_path)
      end
    end
  end
end
