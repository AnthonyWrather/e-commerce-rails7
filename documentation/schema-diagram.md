# Database Schema Diagram

```mermaid
erDiagram
    categories ||--o{ products : "has many"
    products ||--o{ stocks : "has many"
    products ||--o{ order_products : "has many"
    orders ||--o{ order_products : "has many"
    active_storage_blobs ||--o{ active_storage_attachments : "has many"
    active_storage_blobs ||--o{ active_storage_variant_records : "has many"

    categories {
        bigint id PK
        string name
        text description
        datetime created_at
        datetime updated_at
    }

    products {
        bigint id PK
        string name
        text description
        integer price "in pence"
        integer category_id FK
        boolean active
        datetime created_at
        datetime updated_at
        integer amount "stock level"
        integer weight "in grams"
        integer length "in cm"
        integer width "in cm"
        integer height "in cm"
    }

    stocks {
        bigint id PK
        string size
        integer amount "stock level"
        integer product_id FK
        datetime created_at
        datetime updated_at
        integer price "in pence"
        integer weight "in grams"
        integer length "in cm"
        integer width "in cm"
        integer height "in cm"
    }

    orders {
        bigint id PK
        string customer_email
        boolean fulfilled
        integer total "in pence"
        string address
        datetime created_at
        datetime updated_at
        string name
        string phone
        string billing_name
        string billing_address
        string payment_status
        string payment_id
        integer shipping_cost "in pence"
        string shipping_id
        string shipping_description
    }

    order_products {
        bigint id PK
        integer product_id FK
        integer order_id FK
        string size
        integer quantity
        datetime created_at
        datetime updated_at
        integer price "captured at purchase"
    }

    admin_users {
        bigint id PK
        string email UK
        string encrypted_password
        string reset_password_token UK
        datetime reset_password_sent_at
        datetime remember_created_at
        datetime created_at
        datetime updated_at
    }

    active_storage_blobs {
        bigint id PK
        string key UK
        string filename
        string content_type
        text metadata
        string service_name
        bigint byte_size
        string checksum
        datetime created_at
    }

    active_storage_attachments {
        bigint id PK
        string name
        string record_type
        bigint record_id
        bigint blob_id FK
        datetime created_at
    }

    active_storage_variant_records {
        bigint id PK
        bigint blob_id FK
        string variation_digest
    }

    products_backup {
        bigint id PK
        string name
        text description
        integer price
        integer category_id
        boolean active
        datetime created_at
        datetime updated_at
        integer amount
        integer weight
        integer length
        integer width
        integer height
    }

    stocks_backup {
        bigint id PK
        string size
        integer amount
        integer product_id
        datetime created_at
        datetime updated_at
        integer price
        integer weight
        integer length
        integer width
        integer height
    }
```

## Key Relationships

### Core E-Commerce Flow
- **categories → products**: One category can have many products
- **products → stocks**: One product can have many size variants (stocks)
- **products → order_products**: Products can appear in multiple orders
- **orders → order_products**: One order contains multiple products

### Active Storage (Images)
- **active_storage_blobs → active_storage_attachments**: Polymorphic relationship
  - Products: `has_many_attached :images`
  - Categories: `has_one_attached :image`
- **active_storage_blobs → active_storage_variant_records**: Image variants (thumb, medium)

### Authentication
- **admin_users**: Standalone table (Devise authentication)
  - No foreign key relationships to other tables
  - Only admins have accounts, customers checkout as guests

### Backup Tables
- **products_backup**: Historical snapshot of products table
- **stocks_backup**: Historical snapshot of stocks table
- These are likely from data migration work

## Pricing Model
The schema supports two pricing strategies:

1. **Single Price**: Product has `price` and `amount` directly
2. **Variant Pricing**: Product has multiple Stocks, each with their own `price` and `amount`

## Important Notes
- All prices stored in **pence** (integer)
- All weights in **grams** (integer)
- All dimensions in **cm** (integer)
- `order_products.price` captures the price at time of purchase (not calculated)
- Orders created via Stripe webhook only (no direct user creation)

