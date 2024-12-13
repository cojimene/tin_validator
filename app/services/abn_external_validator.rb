require 'net/http'
require 'uri'

class AbnExternalValidator < ApplicationService
  # This should be an env var, but I'm just going to leave here by now
  EXTERNAL_SERVER_URL = 'http://localhost:8080'

  attr_reader :business_name, :business_address, :error

  def initialize(number)
    @number = number
  end

  def call
    response = get_response
    parse_response(response)
    self
  end

  private

  def get_response
    uri = URI.parse("#{EXTERNAL_SERVER_URL}/queryABN?abn=#{@number}")
    Net::HTTP.get_response(uri)
  end

  def parse_response(response)
    if response.code == '500'
      @error = 'registration API could not be reached'
    elsif response.code == '404'
      @error = 'business is not registered'
    else
      business_entity = Hash.from_xml(response.body).dig('abn_response', 'response', 'businessEntity')

      if business_entity['goodsAndServicesTax'] == 'true'
        @business_name = business_entity['organisationName']
        @business_address = business_entity['address']&.values&.join(', ')
      else
        @error = 'business is not GST registered'
      end
    end
  end
end