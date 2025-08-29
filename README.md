# README

* This is a demo project based on a tutorial from Conner Jensen.

> This is the repo that goes along with my Fullstack E-Commerce app tutorial.
> Check it out here <https://youtu.be/hURUMwdCWuI?si=YxSO5hpRAESz6rEU>

* About E-Commerce-Rails7

Things you may want to cover:

* Ruby version
`3.2.2`

* Configuration
Add your env variables to the `config/credentials.yml.enc` file. You can do this by running `bin/rails credentials:edit`

* Database creation
Locally we use sqlite3 as our database. This is already set up for you. In production make sure your `DATABASE_URL` env variable is set. We use PostgreSQL in production.

* Database initialization
run `bin/rails db:migrate` to create the tables

* Deployment instructions
We deploy on Render create a free account here render.com

* Initial Dev setup
You need to build the Tailwind components before you can start the server.

```bash
bin/rails tailwindcss:build
bin/rails s
bin/rails tailwindcss:watch
```

Next you need to add 1 or more admin users.

```bash
bin/rails c
```

```ruby
Admin.create(email: "admin1@example.com", password: "12345678")
Admin.create(email: "admin2@example.com", password: "12345678")
```

You might need to install VIPS if running locally.

```bash
brew install vips
```

To build the Dockerfile you need to run

```bash
docker build -f Dockerfile -t e-commerce-rails7 .
docker run -p 3000:3000 -v $(PWD):/rails e-commerce-rails7
```

Setup DevContainers with postgresql

The devcontainer's are setup but the app is still using sqlite.

Change the app to use postgresql and pgadmin.

```bash
rails db:system:change --to=postgresql

EDITOR="code --wait" rails credentials:edit
```

The pgadmin web interface can be found here <localhost:15432> and needs user(postgres)/password(postgres)/host(postgres).

You can also run pgadmin locally and connect via <localhost:5432>

Added the VSCode extensions to autoload.

```json
// Configure tool-specific properties.
"customizations": {
  // Configure properties specific to VS Code.
  "vscode": {
    // Set *default* container specific settings.json values on container create.
    "settings": {},
    "extensions": [
      "streetsidesoftware.code-spell-checker",
      "ms-azuretools.vscode-containers",
      "p1c2u.docker-compose",
      "aliariff.vscode-erb-beautify",
      "github.vscode-github-actions",
      "mohd-akram.vscode-html-format",
      "oderwat.indent-rainbow",
      "bierner.markdown-preview-github-styles",
      "ms-ossdata.vscode-pgsql",
      "esbenp.prettier-vscode",
      "shopify.ruby-lsp",
      "castwide.solargraph",
      "hoovercj.ruby-linter",
      "misogi.ruby-rubocop",
      "miguel-savignano.ruby-symbols",
      "bradlc.vscode-tailwindcss",
      "austenc.tailwind-docs",
      "zarifprogrammer.tailwind-snippets",
      "heybourn.headwind",
      "gruntfuggly.todo-tree",
      "redhat.vscode-yaml",
      "vscode-icons-team.vscode-icons",
      "davidanson.vscode-markdownlint",
      "hridoy.rails-snippets",
      "kaiwood.endwise",
      "manuelpuyol.erb-linter"
    ]
  }
}
```

Robocop playtime...

```bash
# Run the safe only cops.
rubocop -a

# Run the safe and unsafe cops.
# Beware there are dragons in there...
rubocop -A

# To run only a set of the cops.
rubocop --only Style/Documentation

# To run and fix just a set of cops.
rubocop --only Style/FrozenStringLiteralComment -A
```

The final rubocop.yml file is

```yml
# The behavior of RuboCop can be controlled via the .rubocop.yml
# configuration file. It makes it possible to enable/disable
# certain cops (checks) and to alter their behavior if they accept
# any parameters. The file can be placed either in your home
# directory or in some project directory.
#
# RuboCop will start looking for the configuration file in the directory
# where the inspected file is and continue its way up to the root directory.
#
# See https://docs.rubocop.org/rubocop/configuration

AllCops:
  NewCops: enable
  SuggestExtensions: false

Style/Documentation:
  Enabled: false

Layout/LineLength:
  Enabled: false

Metrics/BlockLength:
  Enabled: false

Metrics/AbcSize:
  Enabled: false

Metrics/MethodLength:
  Enabled: false

Metrics/PerceivedComplexity:
  Enabled: false

Metrics/CyclomaticComplexity:
  Enabled: false

# Examine these changes to see what breaks.
Style/ClassAndModuleChildren:
  Enabled: false

Style/ConditionalAssignment:
  Enabled: false

Style/IfUnlessModifier:
  Enabled: false

Style/SafeNavigation:
  Enabled: false

Style/SlicingWithRange:
  Enabled: false

Lint/NonLocalExitFromIterator:
  Enabled: false
```

Changed the currency from USD to GBP

Add a price to the stock record so each variant can have its own price.

```bash
bin/rails generate migration AddPriceToStock
```

Add an amount to the product record so that a single priced item can have a stock level.

```bash
bin/rails generate migration AddAmountToProduct
```

Add a price to the order_products table so we can record the line item prices.

```bash
bin/rails generate migration AddPriceToOrderProducts
```

Added Render to Slack integration so there is a notification of each deployment.
