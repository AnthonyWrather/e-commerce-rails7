# frozen_string_literal: true

require 'csv'

class Admin::AuditLogsController < AdminController
  before_action :set_filter_params

  def index
    versions = PaperTrail::Version.order(created_at: :desc)
    versions = apply_filters(versions)
    @pagy, @versions = pagy(versions, items: 25)
  end

  def export
    versions = PaperTrail::Version.order(created_at: :desc)
    versions = apply_filters(versions)

    respond_to do |format|
      format.csv do
        send_data generate_csv(versions),
                  filename: "audit_log_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
                  type: 'text/csv'
      end
    end
  end

  private

  def set_filter_params
    @item_types = PaperTrail::Version.distinct.pluck(:item_type).sort
    @events = PaperTrail::Version.distinct.pluck(:event).sort
    @users = PaperTrail::Version.distinct.pluck(:whodunnit).compact.sort
  end

  def apply_filters(versions)
    versions = versions.where(item_type: params[:item_type]) if params[:item_type].present?
    versions = versions.where(event: params[:event]) if params[:event].present?
    versions = versions.where(whodunnit: params[:user]) if params[:user].present?
    filter_by_date_range(versions)
  end

  def filter_by_date_range(versions)
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      versions = versions.where('created_at >= ?', start_date)
    end

    if params[:end_date].present?
      end_date = Date.parse(params[:end_date]).end_of_day
      versions = versions.where('created_at <= ?', end_date)
    end

    versions
  end

  def generate_csv(versions)
    CSV.generate(headers: true) do |csv|
      csv << ['Timestamp', 'User', 'Event', 'Item Type', 'Item ID', 'Changes']

      versions.find_each do |version|
        csv << [
          version.created_at.strftime('%Y-%m-%d %H:%M:%S'),
          version.whodunnit || 'System',
          version.event,
          version.item_type,
          version.item_id,
          format_changes_for_csv(version)
        ]
      end
    end
  end

  def format_changes_for_csv(version)
    return '' unless version.object_changes

    changes = YAML.safe_load(version.object_changes, permitted_classes: [Time, Date, BigDecimal])
    return '' unless changes.is_a?(Hash)

    changes.map { |key, values| "#{key}: #{values[0]} → #{values[1]}" }.join('; ')
  rescue StandardError
    ''
  end
end
