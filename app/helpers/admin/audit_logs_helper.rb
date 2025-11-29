# frozen_string_literal: true

module Admin::AuditLogsHelper
  def event_badge_class(event)
    case event
    when 'create'
      'bg-green-100 text-green-800'
    when 'update'
      'bg-blue-100 text-blue-800'
    when 'destroy'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def render_version_changes(version)
    return no_changes_tag unless version.object_changes

    changes = parse_changes(version.object_changes)
    return no_changes_tag unless changes.is_a?(Hash)

    filtered_changes = changes.except('created_at', 'updated_at')
    return no_significant_changes_tag if filtered_changes.empty?

    render_changes_list(filtered_changes)
  rescue StandardError
    content_tag(:span, 'Unable to parse changes', class: 'text-gray-400 italic')
  end

  private

  def no_changes_tag
    content_tag(:span, 'No changes recorded', class: 'text-gray-400 italic')
  end

  def no_significant_changes_tag
    content_tag(:span, 'No significant changes', class: 'text-gray-400 italic')
  end

  def parse_changes(object_changes)
    YAML.safe_load(object_changes, permitted_classes: [Time, Date, BigDecimal])
  end

  def render_changes_list(filtered_changes)
    content_tag(:div, class: 'space-y-1') do
      items = filtered_changes.first(5).map { |key, values| render_change_item(key, values) }
      items << overflow_tag(filtered_changes.size) if filtered_changes.size > 5
      safe_join(items)
    end
  end

  def render_change_item(key, values)
    content_tag(:div, class: 'text-xs') do
      safe_join([
                  content_tag(:span, key.humanize, class: 'font-medium'),
                  ': ',
                  content_tag(:span, format_value(values[0]), class: 'text-gray-500 line-through'),
                  ' → ',
                  content_tag(:span, format_value(values[1]), class: 'text-green-600')
                ])
    end
  end

  def overflow_tag(total_size)
    content_tag(:span, "... and #{total_size - 5} more", class: 'text-gray-400 text-xs')
  end

  def format_value(value)
    return 'nil' if value.nil?
    return value.strftime('%Y-%m-%d %H:%M') if value.is_a?(Time) || value.is_a?(DateTime)
    return value.strftime('%Y-%m-%d') if value.is_a?(Date)

    value.to_s.truncate(50)
  end
end
