class TinValidator < ApplicationService
  attr_reader :type, :formatted_number, :errors, :business_registration

  ABN_WEIGHTS = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19].freeze
  ABN_MODULUS = 89

  def initialize(country, number)
    @country = country
    @number = number.to_s
    @valid = false
  end

  def call
    check_number
    @errors ||= 'invalid number' unless valid?
    self
  end

  def valid?
    @valid
  end

  private

  def check_number
    case @country
    when 'AU' then check_australia
    when 'CA' then check_canada
    when 'IN' then check_india
    end
  end

  def check_canada
    if tin_valid = @number.match(/\A(\d{9})(RT0001)?\z/)
      @formatted_number = "#{tin_valid[1]}RT0001"
      @valid = true
      @type = 'ca_gst'
    end
  end

  def check_australia
    @valid = true

    if @number.match(/\A\d{9}\z/)
      @formatted_number = "#{@number[0..2]} #{@number[3..5]} #{@number[6..8]}"
      @type = 'au_acn'
    elsif @number.match(/\A\d{3} \d{3} \d{3}\z/)
      @formatted_number = @number
      @type = 'au_acn'
    elsif @number.match(/\A(\d{11}|\d{2} \d{3} \d{3} \d{3})\z/)
      validate_abn_from_external_server
    else
      @valid = false
    end
  end

  def check_india
    if @number.match(/\A\d{2}[0-9A-Z]{10}\d[A-Z]\d\z/)
      @formatted_number = @number
      @type = 'in_gst'
      @valid = true
    end
  end

  def validate_abn_from_external_server
    @number.gsub!(/\s+/, '')
    validator = AbnExternalValidator.call(@number)

    if validator.error
      @errors = validator.error
      @valid = false
    else
      @formatted_number = "#{@number[0..1]} #{@number[2..4]} #{@number[5..7]} #{@number[8..10]}"
      @type = 'au_acn'
      @business_registration = {name: validator.business_name, address: validator.business_address}
    end
  end
end