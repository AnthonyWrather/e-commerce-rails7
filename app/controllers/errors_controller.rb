# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_honeybadger_context
  skip_before_action :set_paper_trail_whodunnit
  skip_before_action :set_honeybadger_user_context

  def not_found
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'not_found')
    respond_to do |format|
      format.html { render :not_found, status: 404 }
      format.json { render json: { error: 'Not Found', error_id: @error_id }, status: 404 }
    end
  end

  def unprocessable_entity
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'unprocessable_entity')
    respond_to do |format|
      format.html { render :unprocessable_entity, status: 422 }
      format.json { render json: { error: 'Unprocessable Entity', error_id: @error_id }, status: 422 }
    end
  end

  def internal_server_error
    @error_id = generate_error_id
    Honeybadger.context(error_id: @error_id, error_type: 'internal_server_error')
    respond_to do |format|
      format.html { render :internal_server_error, status: 500 }
      format.json do
        render json: { error: 'Internal Server Error', error_id: @error_id }, status: 500
      end
    end
  end

  private

  def generate_error_id
    "ERR-#{SecureRandom.hex(6).upcase}"
  end
end
