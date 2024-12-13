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

    context 'when is an ABN number' do
      let(:abn_external) { instance_double(AbnExternalValidator) }
      before { allow(AbnExternalValidator).to receive(:call).and_return(abn_external) }

      it 'responses invalid with 10000000000' do
        allow(abn_external).to receive(:error).and_return('business is not GST registered')

        post '/tin_validations', params: {tin_validation: {country: 'AU', number: '10000000000'}}

        expect(parsed_response['valid']).to eq(false)
        expect(parsed_response['errors']).to include('business is not GST registered')
      end

      it 'responses valid with 10120000004' do
        allow(abn_external).to receive(:error).and_return(nil)
        allow(abn_external).to receive(:business_address).and_return('Test address')
        allow(abn_external).to receive(:business_name).and_return('Test name')

        post '/tin_validations', params: {tin_validation: {country: 'AU', number: '10120000004'}}

        expect(parsed_response['valid']).to eq(true)
        expect(parsed_response['formatted_tin']).to eq('10 120 000 004')
        expect(parsed_response['business_registration']['name']).to include('Test name')
        expect(parsed_response['business_registration']['address']).to eq('Test address')
      end

      it 'responses errors with 53004085616' do
        allow(abn_external).to receive(:error).and_return('registration API could not be reached')
        post '/tin_validations', params: {tin_validation: {country: 'AU', number: '53004085616'}}

        expect(parsed_response['valid']).to eq(false)
        expect(parsed_response['errors']).to include('registration API could not be reached')
      end

      it 'responses errors with 51824753556' do
        allow(abn_external).to receive(:error).and_return('business is not registered')
        post '/tin_validations', params: {tin_validation: {country: 'AU', number: '51824753556'}}

        expect(parsed_response['valid']).to eq(false)
        expect(parsed_response['errors']).to include('business is not registered')
      end
    end

    it 'responses errors with any other format not ABN' do
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