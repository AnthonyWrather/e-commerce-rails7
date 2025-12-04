# frozen_string_literal: true

class Admin::DataManagementController < AdminController
  before_action :validate_tables, only: %i[export clear]
  before_action :validate_import_file, only: [:import]

  def index
    # Show the data management page
  end

  def export
    service = DataManagementService.new
    data = service.export(selected_tables)

    if service.results[:errors].any?
      flash[:error] = "Export completed with errors: #{format_errors(service.results[:errors])}"
    end

    send_data(
      JSON.pretty_generate(data),
      filename: "data_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json",
      type: 'application/json',
      disposition: 'attachment'
    )
  end

  def clear
    service = DataManagementService.new
    service.clear(selected_tables)

    if service.results[:errors].any?
      flash[:error] = "Clear completed with errors: #{format_errors(service.results[:errors])}"
    else
      flash[:notice] = "Successfully cleared data from: #{selected_tables.join(', ')}"
    end

    redirect_to admin_data_management_index_path
  end

  def import
    results = perform_import
    handle_import_flash_messages(results)
    redirect_to admin_data_management_index_path
  rescue JSON::ParserError => e
    flash[:error] = "Invalid JSON file: #{e.message}"
    redirect_to admin_data_management_index_path
  rescue StandardError => e
    flash[:error] = "Import failed: #{e.message}"
    redirect_to admin_data_management_index_path
  end

  private

  def perform_import
    service = DataManagementService.new
    data = JSON.parse(params[:import_file].read)
    service.import(data)
    service.results
  end

  def handle_import_flash_messages(results)
    if results[:errors].any?
      error_message = format_errors(results[:errors])
      flash[:error] = "Import completed with #{results[:errors].count} error(s): #{error_message}"
    end

    flash[:notice] = "Successfully imported #{results[:success].count} record(s)"
  end

  def selected_tables
    tables = params[:tables] || DataManagementService::TABLES
    tables = [tables] if tables.is_a?(String)
    tables & DataManagementService::TABLES
  end

  def validate_tables
    return if selected_tables.any?

    flash[:error] = 'Please select at least one table'
    redirect_to admin_data_management_index_path
  end

  def validate_import_file
    return if params[:import_file].present?

    flash[:error] = 'Please select a file to import'
    redirect_to admin_data_management_index_path
  end

  def format_errors(errors)
    errors.map { |e| "#{e[:table]}: #{e[:error]}" }.join('; ')
  end
end
