# encoding: utf-8

module Shutterbug
  class Rackapp

    def initialize(app, &block)
      @config = Configuration.instance
      yield @config if block_given?
      @app = app
      @shutterbug = Service.new(@config)
      log "initialized"
    end

    def do_convert(req)
      html     = req.POST()['content']  ||  ""
      width    = req.POST()['width']    || 1000
      height   = req.POST()['height']   ||  700
      css      = req.POST()['css']      ||  ""

      signature = @shutterbug.convert(@config.base_url(req), html, css, width, height)
      response_text = "<img src='#{@config.png_path(signature)}' alt='#{signature}'>"
      return good_response(response_text,'text/plain')
    end

    def do_convert_pdf(req)
      html     = req.POST()['content']  ||  ""
      width    = req.POST()['width']    || 1000
      height   = req.POST()['height']   ||  700
      css      = req.POST()['css']      ||  ""

      signature = @shutterbug.convert(@config.base_url(req), html, css, width, height)
      response_text = "<object data='#{@config.pdf_path(signature)}' type='application/pdf'>"
      return good_response(response_text,'text/plain')
    end

    def do_generate_pdf(req)
      html     = req.POST()['content']  ||  ""
      width    = req.POST()['width']    || 1000
      height   = req.POST()['height']   ||  700
      css      = req.POST()['css']      ||  ""

      signature = @shutterbug.convert(@config.base_url(req), html, css, width, height)
      response_text = "<a href='#{@config.pdf_path(signature)}' target='_blank'>PDF link</a>"
      return good_response(response_text,'text/plain')
    end

    def call env
      req = Rack::Request.new(env)
      case req.path
      when @config.convert_regex
        do_convert(req)
      when @config.convert_pdf_regex
        do_convert_pdf(req)
      when @config.generate_pdf_regex
        do_generate_pdf(req)
      when @config.png_regex
        good_response(@shutterbug.get_png_file($1),'image/png')
      when @config.pdf_regex
        good_response(@shutterbug.get_pdf_file($1),'application/pdf')
      when @config.html_regex
        good_response(@shutterbug.get_html_file($1),'text/html')
      when @config.js_regex
        good_response(@shutterbug.get_shutterbug_file, 'application/javascript')
      else
        skip(env)
      end
    end

    private
    def good_response(content, type, cache='no-cache')
      headers = {}
      headers['Content-Length'] = content.size.to_s
      headers['Content-Type']   = type
      headers['Cache-Control']  = 'no-cache'
      # content must be enumerable.
      content = [content] if content.kind_of? String
      return [200, headers, content]
    end

    def log(string)
      puts "★ shutterbug #{Shutterbug::VERSION} ➙ #{string}"
    end

    def skip(env)
      # call the applicaiton default
      @app.call env
    end

  end
end
