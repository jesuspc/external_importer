require 'net/http'
require_relative 'constant_store'
Dir[ File.dirname(__FILE__) + "/importers/*.rb" ].each { |file| require file }

class ExternalImport

  extend ConstantStore

  constant_stores :known_endpoints, :as => :hash

  def initialize format, options = {}
    @format = format
    @source = options[:source]
  end

  def from source
    @source = source
    self
  end

  def with options = {}
    @content = block_given? ? yield.to_param : options.to_param
    self
  end

  def import object_receiver_hash, options = {}, &block
    @object          = object_receiver_hash.keys.first
    @import_receiver = object_receiver_hash[ @object ]

    response = perform_request_to_url
    import_given response, options, &block
  end

private

  def base_uri
    begin
      KNOWN_ENDPOINTS[ @source ][ @object ]
    rescue
      @source
    end
  end

  def urlized_source
    uri_string = @content ? ( base_uri + "?#{@content}" ) : base_uri
    
    URI.parse uri_string
  end

  def perform_request_to_url
    url_object = urlized_source

    Net::HTTP.start( url_object.host, url_object.port ) do |http|
      http.request Net::HTTP::Get.new( url_object.to_s )
    end
  end

  def import_given net_http_response, options = {}, &block
    importer = "#{@format}Importer".classify.constantize
    importer.import net_http_response, @object, @import_receiver, options, &block
  end

end