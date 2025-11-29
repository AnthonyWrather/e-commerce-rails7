# frozen_string_literal: true

require 'test_helper'

module Admin
  class AuditLogsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in admin_users(:admin_user_one)
    end

    test 'should get index' do
      get admin_audit_logs_url
      assert_response :success
      assert_select 'h1', 'Audit Logs'
    end

    test 'should filter by item_type' do
      product = products(:product_one)
      product.update!(name: 'Updated Product')

      get admin_audit_logs_url, params: { item_type: 'Product' }
      assert_response :success
    end

    test 'should filter by event' do
      product = products(:product_one)
      product.update!(name: 'Test Update')

      get admin_audit_logs_url, params: { event: 'update' }
      assert_response :success
    end

    test 'should filter by date range' do
      get admin_audit_logs_url, params: {
        start_date: 1.day.ago.to_date.to_s,
        end_date: Date.today.to_s
      }
      assert_response :success
    end

    test 'should export csv' do
      product = products(:product_one)
      product.update!(name: 'Export Test')

      get export_admin_audit_logs_url(format: :csv)
      assert_response :success
      assert_equal 'text/csv', response.content_type.split(';').first
    end

    test 'audit logs link visible in admin layout' do
      get admin_audit_logs_url
      assert_select 'a[href=?]', admin_audit_logs_path
    end
  end
end
