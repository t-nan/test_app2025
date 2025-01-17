class Api::V1::UsersController < ApplicationController
  def create
    outcome = Api::V1::Users::Create.run(params)

    return render json: {
      errors: outcome.errors.attribute_names.map { |attr| { key: attr, messages: outcome.errors.full_messages_for(attr) } },
      success: false
    }, status: :unprocessable_entity if outcome.errors.present?

    render json: { success: true } unless outcome.errors.present?
  end
end
