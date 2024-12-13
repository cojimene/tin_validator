class TinValidator < ApplicationService
  attr_reader :type, :formatted_number, :errors

  ABN_WEIGHTS = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19].freeze
  ABN_MODULUS = 89

  def initialize(country, number)
    @country = country
    @number = number.to_s
    @valid = false
  end

  def call
    check_number
    @errors = 'invalid number' unless valid?
    self
  end

  def valid?
    @valid
  end

  private

  def check_number
    case @country
    when 'AU' then check_au
    when 'CA' then check_ca
    when 'IN' then check_in
    end
  end

  def check_ca
    if tin_valid = @number.match(/\A(\d{9})(RT0001)?\z/)
      @formatted_number = "#{tin_valid[1]}RT0001"
      @valid = true
      @type = 'ca_gst'
    end
  end

  def check_au
    @valid = true

    if @number.match(/\A\d{9}\z/)
      @formatted_number = "#{@number[0..2]} #{@number[3..5]} #{@number[6..8]}"
      @type = 'au_acn'
    elsif @number.match(/\A\d{3} \d{3} \d{3}\z/)
      @formatted_number = @number
      @type = 'au_acn'
    elsif @number.match(/\A(\d{11}|\d{2} \d{3} \d{3} \d{3})\z/) && abn_format?
      @number.gsub!(/\s+/, '')
      @formatted_number = "#{@number[0..1]} #{@number[2..4]} #{@number[5..7]} #{@number[8..10]}"
      @type = 'au_abn'
    else
      @valid = false
    end
  end

  def check_in
    if @number.match(/\A\d{2}[0-9A-Z]{10}\d[A-Z]\d\z/)
      @formatted_number = @number
      @type = 'in_gst'
      @valid = true
    end
  end

  def abn_format?
    number = "#{(@number[0].to_i - 1)}#{@number[1..]}" # rest 1 from the first digit
    total = 0

    # sum the products digits*weigth
    number.chars.each_with_index do |d, i|
      total += d.to_i * ABN_WEIGHTS[i]
    end

    (total % ABN_MODULUS) == 0
  end
end