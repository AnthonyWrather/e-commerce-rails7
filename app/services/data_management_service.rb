# frozen_string_literal: true

class DataManagementService
  class DataManagementError < StandardError; end

  TABLES = %w[categories products stocks orders order_products carts cart_items conversations messages
              conversation_participants].freeze

  attr_reader :results

  def initialize
    @results = { success: [], errors: [] }
  end

  # Export data for specified tables
  def export(tables = TABLES)
    data = {}
    tables.each do |table|
      data[table] = export_table(table)
    rescue StandardError => e
      @results[:errors] << { table: table, action: 'export', error: e.message }
    end
    data
  end

  # Clear data for specified tables
  def clear(tables = TABLES)
    # Clear in dependency order: stocks -> products -> categories
    ordered_tables = order_for_clearing(tables)
    ordered_tables.each do |table|
      clear_table(table)
      @results[:success] << { table: table, action: 'clear' }
    rescue StandardError => e
      @results[:errors] << { table: table, action: 'clear', error: e.message }
    end
    @results
  end

  # Import data from JSON
  def import(data)
    # Import in dependency order: categories -> products -> stocks
    ordered_tables = order_for_importing(data.keys)
    ordered_tables.each do |table|
      import_table(table, data[table])
    end
    @results
  end

  private

  def export_table(table)
    case table
    when 'categories'
      export_categories
    when 'products'
      export_products
    when 'stocks'
      export_stocks
    when 'orders'
      export_orders
    when 'order_products'
      export_order_products
    when 'carts'
      export_carts
    when 'cart_items'
      export_cart_items
    when 'conversations'
      export_conversations
    when 'messages'
      export_messages
    when 'conversation_participants'
      export_conversation_participants
    else
      raise DataManagementError, "Unknown table: #{table}"
    end
  end

  def export_categories
    Category.all.map do |category|
      category_data = category.attributes.except('id', 'created_at', 'updated_at')
      category_data['image'] = encode_image(category.image) if category.image.attached?
      category_data
    end
  end

  def export_products
    Product.includes(:category, images_attachments: :blob).map do |product|
      product_data = product.attributes.except('id', 'created_at', 'updated_at')
      product_data['category_name'] = product.category.name
      product_data.delete('category_id')
      product_data['images'] = product.images.attached? ? product.images.map { |img| encode_image_attachment(img) } : []
      product_data
    end
  end

  def export_stocks
    Stock.includes(product: :category).map do |stock|
      stock_data = stock.attributes.except('id', 'created_at', 'updated_at')
      stock_data['product_name'] = stock.product.name
      stock_data['category_name'] = stock.product.category.name
      stock_data.delete('product_id')
      stock_data
    end
  end

  def export_orders
    Order.all.map do |order|
      order.attributes.except('id', 'created_at', 'updated_at')
    end
  end

  def export_order_products
    OrderProduct.includes(:order, product: :category).map do |order_product|
      op_data = order_product.attributes.except('id', 'created_at', 'updated_at')
      op_data['order_customer_email'] = order_product.order.customer_email
      op_data['order_payment_id'] = order_product.order.payment_id
      op_data['product_name'] = order_product.product.name
      op_data['category_name'] = order_product.product.category.name
      op_data.delete('order_id')
      op_data.delete('product_id')
      op_data
    end
  end

  def export_carts
    Cart.includes(:user).map do |cart|
      cart_data = cart.attributes.except('id', 'created_at', 'updated_at')
      cart_data['user_email'] = cart.user&.email
      cart_data.delete('user_id')
      cart_data
    end
  end

  def export_cart_items
    CartItem.includes(:cart, :product, :stock).map do |cart_item|
      item_data = cart_item.attributes.except('id', 'created_at', 'updated_at')
      item_data['cart_session_token'] = cart_item.cart.session_token
      item_data['product_name'] = cart_item.product.name
      item_data['stock_size'] = cart_item.stock&.size
      item_data.delete('cart_id')
      item_data.delete('product_id')
      item_data.delete('stock_id')
      item_data
    end
  end

  def export_conversations
    Conversation.includes(:user).map do |conversation|
      conv_data = conversation.attributes.except('id', 'created_at', 'updated_at')
      conv_data['user_email'] = conversation.user.email
      conv_data.delete('user_id')
      conv_data
    end
  end

  def export_messages
    Message.includes(:conversation, :sender).map do |message|
      msg_data = message.attributes.except('id', 'created_at', 'updated_at')
      msg_data['conversation_user_email'] = message.conversation.user.email
      msg_data['conversation_subject'] = message.conversation.subject
      msg_data['sender_email'] = message.sender&.email
      msg_data.delete('conversation_id')
      msg_data.delete('sender_id')
      msg_data
    end
  end

  def export_conversation_participants
    ConversationParticipant.includes(:conversation, :admin_user).map do |participant|
      part_data = participant.attributes.except('id', 'created_at', 'updated_at')
      part_data['conversation_user_email'] = participant.conversation.user.email
      part_data['conversation_subject'] = participant.conversation.subject
      part_data['admin_user_email'] = participant.admin_user.email
      part_data.delete('conversation_id')
      part_data.delete('admin_user_id')
      part_data
    end
  end

  def encode_image(attachment)
    return nil unless attachment.attached?

    {
      'filename' => attachment.filename.to_s,
      'content_type' => attachment.content_type,
      'data' => Base64.strict_encode64(attachment.download)
    }
  end

  # Encode an ActiveStorage::Attachment directly (already attached)
  def encode_image_attachment(attachment)
    {
      'filename' => attachment.filename.to_s,
      'content_type' => attachment.content_type,
      'data' => Base64.strict_encode64(attachment.download)
    }
  rescue ActiveStorage::FileNotFoundError
    # In test environment, files may not exist
    {
      'filename' => attachment.filename.to_s,
      'content_type' => attachment.content_type,
      'data' => nil
    }
  end

  def order_for_clearing(tables)
    # Clear in reverse dependency order
    order = []
    # Chat-related tables (messages depend on conversations, participants depend on conversations)
    order << 'messages' if tables.include?('messages')
    order << 'conversation_participants' if tables.include?('conversation_participants')
    order << 'conversations' if tables.include?('conversations')
    # Cart-related tables (cart_items depend on carts)
    order << 'cart_items' if tables.include?('cart_items')
    order << 'carts' if tables.include?('carts')
    # Order-related tables
    order << 'order_products' if tables.include?('order_products')
    order << 'orders' if tables.include?('orders')
    # Product-related tables
    order << 'stocks' if tables.include?('stocks')
    order << 'products' if tables.include?('products')
    order << 'categories' if tables.include?('categories')
    order
  end

  def order_for_importing(tables)
    # Import in dependency order
    order = []
    # Product-related tables
    order << 'categories' if tables.include?('categories')
    order << 'products' if tables.include?('products')
    order << 'stocks' if tables.include?('stocks')
    # Order-related tables
    order << 'orders' if tables.include?('orders')
    order << 'order_products' if tables.include?('order_products')
    # Cart-related tables (carts first, then cart_items)
    order << 'carts' if tables.include?('carts')
    order << 'cart_items' if tables.include?('cart_items')
    # Chat-related tables (conversations first, then messages and participants)
    order << 'conversations' if tables.include?('conversations')
    order << 'messages' if tables.include?('messages')
    order << 'conversation_participants' if tables.include?('conversation_participants')
    order
  end

  def clear_table(table)
    case table
    when 'categories'
      clear_categories
    when 'products'
      clear_products
    when 'stocks'
      clear_stocks
    when 'orders'
      clear_orders
    when 'order_products'
      clear_order_products
    when 'carts'
      clear_carts
    when 'cart_items'
      clear_cart_items
    when 'conversations'
      clear_conversations
    when 'messages'
      clear_messages
    when 'conversation_participants'
      clear_conversation_participants
    else
      raise DataManagementError, "Unknown table: #{table}"
    end
  end

  def clear_categories
    # Check for products with order_products references first
    check_order_references_for_products
    # Clear stocks first due to foreign key constraint
    Stock.delete_all
    # Clear product images
    Product.find_each do |product|
      product.images.purge if product.images.attached?
    end
    # Clear category images
    Category.find_each do |category|
      category.image.purge if category.image.attached?
    end
    # Delete all products then categories
    Product.delete_all
    Category.delete_all
  end

  def clear_products
    # Check for products with order_products references first
    check_order_references_for_products
    # Clear product images first
    Product.find_each do |product|
      product.images.purge if product.images.attached?
    end
    # Delete stocks first, then products
    Stock.delete_all
    Product.delete_all
  end

  def check_order_references_for_products
    products_with_orders = Product.joins(:order_products).distinct
    return if products_with_orders.empty?

    raise DataManagementError, 'Cannot delete products that have associated orders. ' \
                               "#{products_with_orders.count} product(s) are referenced by order records."
  end

  def clear_stocks
    Stock.delete_all
  end

  def clear_orders
    # Clear order_products first due to foreign key constraint
    OrderProduct.delete_all
    Order.delete_all
  end

  def clear_order_products
    OrderProduct.delete_all
  end

  def clear_carts
    # Clear cart_items first due to foreign key constraint
    CartItem.delete_all
    Cart.delete_all
  end

  def clear_cart_items
    CartItem.delete_all
  end

  def clear_conversations
    # Clear messages and participants first due to foreign key constraints
    Message.delete_all
    ConversationParticipant.delete_all
    Conversation.delete_all
  end

  def clear_messages
    Message.delete_all
  end

  def clear_conversation_participants
    ConversationParticipant.delete_all
  end

  def import_table(table, records)
    return if records.blank?

    case table
    when 'categories'
      import_categories(records)
    when 'products'
      import_products(records)
    when 'stocks'
      import_stocks(records)
    when 'orders'
      import_orders(records)
    when 'order_products'
      import_order_products(records)
    when 'carts'
      import_carts(records)
    when 'cart_items'
      import_cart_items(records)
    when 'conversations'
      import_conversations(records)
    when 'messages'
      import_messages(records)
    when 'conversation_participants'
      import_conversation_participants(records)
    else
      raise DataManagementError, "Unknown table: #{table}"
    end
  end

  def import_categories(records)
    records.each do |record|
      import_category(record)
    rescue StandardError => e
      @results[:errors] << { table: 'categories', item: record['name'], error: e.message }
    end
  end

  def import_category(record)
    image_data = record.delete('image')
    category = Category.create!(record.except('id', 'created_at', 'updated_at'))
    attach_image(category, :image, image_data) if image_data
    @results[:success] << { table: 'categories', item: category.name }
  end

  def import_products(records)
    records.each do |record|
      import_product(record)
    rescue StandardError => e
      @results[:errors] << { table: 'products', item: record['name'], error: e.message }
    end
  end

  def import_product(record)
    images_data = record.delete('images')
    category_name = record.delete('category_name')

    category = Category.find_by!(name: category_name)
    product = Product.create!(record.except('id', 'created_at', 'updated_at').merge(category: category))

    attach_images(product, images_data) if images_data.present?
    @results[:success] << { table: 'products', item: product.name }
  end

  def import_stocks(records)
    records.each do |record|
      import_stock(record)
    rescue StandardError => e
      @results[:errors] << { table: 'stocks', item: "#{record['product_name']} - #{record['size']}", error: e.message }
    end
  end

  def import_stock(record)
    product_name = record.delete('product_name')
    record.delete('category_name')

    product = Product.find_by!(name: product_name)
    stock = Stock.create!(record.except('id', 'created_at', 'updated_at').merge(product: product))
    @results[:success] << { table: 'stocks', item: "#{product.name} - #{stock.size}" }
  end

  def import_orders(records)
    records.each do |record|
      import_order(record)
    rescue StandardError => e
      @results[:errors] << { table: 'orders', item: record['customer_email'], error: e.message }
    end
  end

  def import_order(record)
    order = Order.create!(record.except('id', 'created_at', 'updated_at'))
    @results[:success] << { table: 'orders', item: order.customer_email }
  end

  def import_order_products(records)
    records.each do |record|
      import_order_product(record)
    rescue StandardError => e
      item_name = "#{record['product_name']} - #{record['size']}"
      @results[:errors] << { table: 'order_products', item: item_name, error: e.message }
    end
  end

  def import_order_product(record)
    order_customer_email = record.delete('order_customer_email')
    order_payment_id = record.delete('order_payment_id')
    product_name = record.delete('product_name')
    record.delete('category_name')

    order = Order.find_by!(customer_email: order_customer_email, payment_id: order_payment_id)
    product = Product.find_by!(name: product_name)
    attributes = record.except('id', 'created_at', 'updated_at').merge(order: order, product: product)
    order_product = OrderProduct.create!(attributes)
    @results[:success] << { table: 'order_products', item: "#{product.name} - #{order_product.size}" }
  end

  def import_carts(records)
    records.each do |record|
      import_cart(record)
    rescue StandardError => e
      @results[:errors] << { table: 'carts', item: record['session_token'], error: e.message }
    end
  end

  def import_cart(record)
    user_email = record.delete('user_email')
    user = user_email.present? ? User.find_by(email: user_email) : nil

    cart = Cart.create!(record.except('id', 'created_at', 'updated_at').merge(user: user))
    @results[:success] << { table: 'carts', item: cart.session_token }
  end

  def import_cart_items(records)
    records.each do |record|
      import_cart_item(record)
    rescue StandardError => e
      item_name = "#{record['product_name']} - #{record['size']}"
      @results[:errors] << { table: 'cart_items', item: item_name, error: e.message }
    end
  end

  def import_cart_item(record)
    cart_session_token = record.delete('cart_session_token')
    product_name = record.delete('product_name')
    stock_size = record.delete('stock_size')

    cart = Cart.find_by!(session_token: cart_session_token)
    product = Product.find_by!(name: product_name)
    stock = stock_size.present? ? product.stocks.find_by(size: stock_size) : nil

    attributes = record.except('id', 'created_at', 'updated_at').merge(cart: cart, product: product, stock: stock)
    cart_item = CartItem.create!(attributes)
    @results[:success] << { table: 'cart_items', item: "#{product.name} - #{cart_item.size}" }
  end

  def import_conversations(records)
    records.each do |record|
      import_conversation(record)
    rescue StandardError => e
      @results[:errors] << { table: 'conversations', item: record['subject'], error: e.message }
    end
  end

  def import_conversation(record)
    user_email = record.delete('user_email')
    user = User.find_by!(email: user_email)

    conversation = Conversation.create!(record.except('id', 'created_at', 'updated_at').merge(user: user))
    @results[:success] << { table: 'conversations', item: conversation.subject }
  end

  def import_messages(records)
    records.each do |record|
      import_message(record)
    rescue StandardError => e
      @results[:errors] << { table: 'messages', item: record['content']&.truncate(30), error: e.message }
    end
  end

  def import_message(record)
    conversation_user_email = record.delete('conversation_user_email')
    conversation_subject = record.delete('conversation_subject')
    sender_email = record.delete('sender_email')
    sender_type = record['sender_type']

    conversation = Conversation.joins(:user).find_by!(users: { email: conversation_user_email }, subject: conversation_subject)
    sender = find_sender(sender_type, sender_email)

    attributes = record.except('id', 'created_at', 'updated_at').merge(conversation: conversation, sender: sender)
    message = Message.create!(attributes)
    @results[:success] << { table: 'messages', item: message.content.truncate(30) }
  end

  def find_sender(sender_type, sender_email)
    return nil unless sender_email.present?

    case sender_type
    when 'User'
      User.find_by!(email: sender_email)
    when 'AdminUser'
      AdminUser.find_by!(email: sender_email)
    end
  end

  def import_conversation_participants(records)
    records.each do |record|
      import_conversation_participant(record)
    rescue StandardError => e
      @results[:errors] << { table: 'conversation_participants', item: record['admin_user_email'], error: e.message }
    end
  end

  def import_conversation_participant(record)
    conversation_user_email = record.delete('conversation_user_email')
    conversation_subject = record.delete('conversation_subject')
    admin_user_email = record.delete('admin_user_email')

    conversation = Conversation.joins(:user).find_by!(users: { email: conversation_user_email }, subject: conversation_subject)
    admin_user = AdminUser.find_by!(email: admin_user_email)

    attributes = record.except('id', 'created_at', 'updated_at').merge(conversation: conversation, admin_user: admin_user)
    ConversationParticipant.create!(attributes)
    @results[:success] << { table: 'conversation_participants', item: admin_user.email }
  end

  def attach_image(record, attribute, image_data)
    return unless image_data

    decoded_data = Base64.decode64(image_data['data'])
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(decoded_data),
      filename: image_data['filename'],
      content_type: image_data['content_type']
    )
    record.send(attribute).attach(blob)
  end

  def attach_images(product, images_data)
    return if images_data.blank?

    images_data.each do |image_data|
      next unless image_data

      decoded_data = Base64.decode64(image_data['data'])
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(decoded_data),
        filename: image_data['filename'],
        content_type: image_data['content_type']
      )
      product.images.attach(blob)
    end
  end
end
