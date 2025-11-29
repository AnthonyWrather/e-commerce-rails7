# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :set_honeybadger_context

  def not_found
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'not_found')
    if request.format.json?
      render json: { error: 'Not Found', error_id: @error_id }, status: :not_found
    else
      render status: :not_found
    end
  end

  def unprocessable_entity
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'unprocessable_entity')
    if request.format.json?
      render json: { error: 'Unprocessable Entity', error_id: @error_id }, status: :unprocessable_entity
    else
      render status: :unprocessable_entity
    end
  end

  def internal_server_error
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'internal_server_error')
    if request.format.json?
      render json: { error: 'Internal Server Error', error_id: @error_id }, status: :internal_server_error
    else
      render status: :internal_server_error
    end
  end

  private

  def generate_error_id
    "ERR-#{SecureRandom.hex(6).upcase}"
  end
end
