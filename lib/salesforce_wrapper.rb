require "salesforce/version"

module Salesforce
  class MissingConfigError < StandardError; end

  class << self
    attr_writer :exception_handler
    attr_accessor :config

    def method_missing(method, *arguments, &block)
      client.send(method, *arguments, &block)
    rescue => exception
      raise exception if exception.is_a? Faraday::Error::ResourceNotFound
      raise exception unless exceptions_to_rescue.any? { |e| exception.is_a? e }
      exception_handler.call(method, exception, arguments)
      false
    end

    def respond_to_missing?(method_name, include_all = false)
      client.respond_to?(method_name) || super
    end

    def client
      return @client if @client

      unless config
        raise MissingConfigError, "You must set Restforce configuration options with " \
                                  "Salesforce.config."
      end

      require "restforce"
      @client ||= Restforce.new(symbolised_config)
    end

    def reset!
      @client = nil
      @exception_handler = lambda { |method, exception, arguments| }
    end

    private

    def symbolised_config
      config.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
    end

    def exception_handler
      @exception_handler ||= lambda { |method, exception, arguments| }
    end

    def exceptions_to_rescue
      [Faraday::Error::ClientError]
    end
  end
end
