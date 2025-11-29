# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :set_honeybadger_context

  def not_found
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'not_found')
    respond_to do |format|
      format.html { render template: 'errors/not_found', status: :not_found }
      format.json { render json: { error: 'Not Found', error_id: @error_id }, status: :not_found }
    end
  end

  def unprocessable_entity
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'unprocessable_entity')
    respond_to do |format|
      format.html { render template: 'errors/unprocessable_entity', status: :unprocessable_entity }
      format.json { render json: { error: 'Unprocessable Entity', error_id: @error_id }, status: :unprocessable_entity }
    end
  end

  def internal_server_error
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'internal_server_error')
    respond_to do |format|
      format.html { render template: 'errors/internal_server_error', status: :internal_server_error }
      format.json do
        render json: { error: 'Internal Server Error', error_id: @error_id }, status: :internal_server_error
      end
    end
  end

  private

  def generate_error_id
    "ERR-#{SecureRandom.hex(6).upcase}"
  end
end
