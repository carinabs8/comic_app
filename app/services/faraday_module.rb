# frozen_string_literal: true

module FaradayModule
  attr_reader :conn, :domain

  def initialize(url_domain = :default_domain)
    @domain = url_domain(url_domain)
    @conn = connection(@domain)
  end

  private

  def publish_catalog_message!(args)
    payload = args[:payload] || ''

    encode = JsonWebToken.encode(payload)
    conn.patch(update_catalog_path) do |req|
      req.headers['Access-Token'] = encode&.data
    end
  end

  def connection(url_domain)
    Faraday.new(
      url: url_domain,
      params: default_params,
      headers: {'Content-Type' => 'application/json'}
    )
  end

  def url_domain(url_domain)
    send(url_domain)
  rescue StandardError
    default_domain
  end

  def default_domain
    'http://localhost:3001'
  end

  def default_params
    {}
  end
end
