module Shutterbug
  class JsFile   < BugFile
    def initialize(_config=Configuration.instance())
      @config = _config
      @javascript = File.read(@config.js_file).gsub(/CONVERT_PATH/,@config.convert_path).gsub(/CONVERT_PDF_PATH/,@config.convert_pdf_path).gsub(/GENERATE_PDF_PATH/,@config.generate_pdf_path)
    end
    def open
      @stream_file = StringIO.new(@javascript)
    end
  end
end