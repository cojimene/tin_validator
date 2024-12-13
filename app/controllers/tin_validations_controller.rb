class TinValidationsController < ApplicationController
  def create
    validator = TinValidator.call(tin_validation_params[:country], tin_validation_params[:number])

    response = {
      valid: validator.valid?,
      tin_type: validator.type,
      formatted_tin: validator.formatted_number,
      errors: [validator.errors]
    }

    render json: response, status: :ok
  end

  private

  def tin_validation_params
    params.require(:tin_validation).permit(:country, :number)
  end
end