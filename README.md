# README

## Tax Identification Number Validation API

### Ruby version
3.3.0

### Test Coverage

Just run `rspec -f d`

### Setup

This app doesn't use any database, so, just install ruby version and run `bundle install`

Then run the server using `rails s`

To run the ABN external validator server, just execute the script `bin/abn_query_server.rb` in another terminal.

To make it work use Postman or your favourite software to make Rest Calls and just make a POST call using these options

URL: `http://localhost:3000/tin_validations`

Headers: `Content-Type: application/json`

Body (example): `{"tin_validation": {"country": "AU", "number": "10000000000"}}`
