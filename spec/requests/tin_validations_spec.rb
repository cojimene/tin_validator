require 'rails_helper'

RSpec.describe 'TinValidations', type: :request do
  def parsed_response
    @parsed_response ||= JSON.parse(response.body)
  end

  context 'when the country is Canada' do
    it 'responses valid with a number like NNNNNNNNN' do
      post '/tin_validations', params: {tin_validation: {country: 'CA', number: '123456789'}}

      expect(parsed_response['valid']).to eq(true)
      expect(parsed_response['formatted_tin']).to eq('123456789RT0001')
      expect(parsed_response['tin_type']).to eq('ca_gst')
    end

    it 'responses valid with a number like NNNNNNNNNRT0001' do
      post '/tin_validations', params: {tin_validation: {country: 'CA', number: '123456789RT0001'}}

      expect(parsed_response['valid']).to eq(true)
      expect(parsed_response['formatted_tin']).to eq('123456789RT0001')
      expect(parsed_response['tin_type']).to eq('ca_gst')
    end

    it 'responses error with any other format' do
      post '/tin_validations', params: {tin_validation: {country: 'CA', number: '1234567893'}}

      expect(parsed_response['valid']).to eq(false)
      expect(parsed_response['errors']).to include('invalid number')
    end
  end

  context 'when the country is Australia' do
    it 'responses valid with a number like NNNNNNNNNNN' do
      post '/tin_validations', params: {tin_validation: {country: 'AU', number: '10120000004'}}

      expect(parsed_response['valid']).to eq(true)
      expect(parsed_response['formatted_tin']).to eq('10 120 000 004')
      expect(parsed_response['tin_type']).to eq('au_abn')
    end

    it 'responses valid with a number like NN NNN NNN NNN' do
      post '/tin_validations', params: {tin_validation: {country: 'AU', number: '10 120 000 004'}}

      expect(parsed_response['valid']).to eq(true)
      expect(parsed_response['formatted_tin']).to eq('10 120 000 004')
      expect(parsed_response['tin_type']).to eq('au_abn')
    end

    it 'responses valid with a number like NNN NNN NNN' do
      post '/tin_validations', params: {tin_validation: {country: 'AU', number: '101 200 000'}}

      expect(parsed_response['valid']).to eq(true)
      expect(parsed_response['formatted_tin']).to eq('101 200 000')
      expect(parsed_response['tin_type']).to eq('au_acn')
    end

    it 'responses valid with a number like NNNNNNNNN' do
      post '/tin_validations', params: {tin_validation: {country: 'AU', number: '101200000'}}

      expect(parsed_response['valid']).to eq(true)
      expect(parsed_response['formatted_tin']).to eq('101 200 000')
      expect(parsed_response['tin_type']).to eq('au_acn')
    end

    it 'responses errors with any other format' do
      post '/tin_validations', params: {tin_validation: {country: 'AU', number: '10 120 0000 004'}}

      expect(parsed_response['valid']).to eq(false)
      expect(parsed_response['errors']).to include('invalid number')
    end
  end

  context 'when the country is India' do
    it 'responses valid with a number like NNXXXXXXXXXXNAN' do
      post '/tin_validations', params: {tin_validation: {country: 'IN', number: '22BCDEF1G2FH1Z5'}}

      expect(parsed_response['valid']).to eq(true)
      expect(parsed_response['formatted_tin']).to eq('22BCDEF1G2FH1Z5')
      expect(parsed_response['tin_type']).to eq('in_gst')
    end

    it 'responses errors with any other format' do
      post '/tin_validations', params: {tin_validation: {country: 'IN', number: '22BCDEF1G2FH1ZA'}}

      expect(parsed_response['valid']).to eq(false)
      expect(parsed_response['errors']).to include('invalid number')
    end
  end
end