# frozen_string_literal: true

module FaradayModule
  attr_reader :conn, :domain

  def initialize
    @domain = default_domain
    @conn = connection(@domain)
  end

  private

  def connection(url_domain)
    Faraday.new(
      url: url_domain,
      params: default_params,
      headers: {'Content-Type' => 'application/json'}
    )
  end

  def default_domain
    'http://localhost:3001'
  end

  def default_params
    {}
  end
end
