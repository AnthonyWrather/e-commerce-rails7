



/awesome-copilot create-readme

--------------------------------

Follow instructions in [create-readme.prompt.md]

Follow instructions in [create-readme.prompt.md](vscode-remote://dev-container%2B7b22686f737450617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c7337222c226c6f63616c446f636b6572223a66616c73652c2273657474696e6773223a7b22636f6e74657874223a226465736b746f702d6c696e7578227d2c22636f6e66696746696c65223a7b22246d6964223a312c22667350617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2265787465726e616c223a2266696c653a2f2f2f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2270617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c22736368656d65223a2266696c65227d7d/workspaces/e-commerce-rails7/.github/prompts/create-readme.prompt.md).

--------------------------------

Analyze this codebase to generate or update `.github/copilot-instructions.md` for guiding AI coding agents.

Focus on discovering the essential knowledge that would help an AI agents be immediately productive in this codebase. Consider aspects like:
- The "big picture" architecture that requires reading multiple files to understand - major components, service boundaries, data flows, and the "why" behind structural decisions
- Critical developer workflows (builds, tests, debugging) especially commands that aren't obvious from file inspection alone
- Project-specific conventions and patterns that differ from common practices
- Integration points, external dependencies, and cross-component communication patterns

Source existing AI conventions from `**/{.github/copilot-instructions.md,AGENT.md,AGENTS.md,CLAUDE.md,.cursorrules,.windsurfrules,.clinerules,.cursor/rules/**,.windsurf/rules/**,.clinerules/**,README.md}` (do one glob search).

Guidelines (read more at https://aka.ms/vscode-instructions-docs):
- If `.github/copilot-instructions.md` exists, merge intelligently - preserve valuable content while updating outdated sections
- Write concise, actionable instructions (~20-50 lines) using markdown structure
- Include specific examples from the codebase when describing patterns
- Avoid generic advice ("write tests", "handle errors") - focus on THIS project's specific approaches
- Document only discoverable patterns, not aspirational practices
- Reference key files/directories that exemplify important patterns

Update `.github/copilot-instructions.md` for the user, then ask for feedback on any unclear or incomplete sections to iterate.

--------------------------------

Analyse the rspec tests

--------------------------------

what other areas of this codebase could be analysed?

--------------------------------

show history

--------------------------------

analyse the Namespace Conflict and suggest a solution

--------------------------------

show key discoveries

--------------------------------

analyse the test errors and suggest the fix

--------------------------------

can you create a diagram of the database tables from the schema.rb

--------------------------------

set the output_folder to .results/ and run all 6 steps and set the final_output_file to /.github/copilot-instructions-bitovi.md. show what you are doing and say when you have finished.

--------------------------------

analyse the render.yaml and check for improvements

--------------------------------

Follow instructions in [suggest-awesome-github-copilot-collections.prompt.md](vscode-remote://dev-container%2B7b22686f737450617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c7337222c226c6f63616c446f636b6572223a66616c73652c2273657474696e6773223a7b22636f6e74657874223a226465736b746f702d6c696e7578227d2c22636f6e66696746696c65223a7b22246d6964223a312c22667350617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2265787465726e616c223a2266696c653a2f2f2f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2270617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c22736368656d65223a2266696c65227d7d/workspaces/e-commerce-rails7/.github/prompts/suggest-awesome-github-copilot-collections.prompt.md).

--------------------------------

In the products and order_products database records, there is a field called amount, rename it to stock_level.
Examine any code changes needed for this change.
Run all tests and fix any broken code or tests.
Do not commit the code.

--------------------------------

can you create a diagram of the database tables from the schema.rb and output the file to documentation/schema-diagram.md

--------------------------------

Write tests for Product model validations (name, price, stock_level,weight,length,width, height)

--------------------------------

Write tests for OrderProduct model validations and ProductStock model validations. Run all tests, fix any errors and run rubocop as the last step. Do not commit the changes.

--------------------------------

Write tests for Calculator business logic (Quantities controllers). Run all tests, fix any errors and run rubocop as the last step. Do not commit the changes.

--------------------------------

Follow instructions in [postgresql-optimization.prompt.md](vscode-remote://dev-container%2B7b22686f737450617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c7337222c226c6f63616c446f636b6572223a66616c73652c2273657474696e6773223a7b22636f6e74657874223a226465736b746f702d6c696e7578227d2c22636f6e66696746696c65223a7b22246d6964223a312c22667350617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2265787465726e616c223a2266696c653a2f2f2f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2270617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c22736368656d65223a2266696c65227d7d/workspaces/e-commerce-rails7/.github/prompts/postgresql-optimization.prompt.md).
Analyse the controllers for N+1 queries and add missing indexes based on db/schema.rb. Run all tests and fix any errors and run rubocop as the last step. Do not commit the code.

--------------------------------

Follow instructions in [postgresql-optimization.prompt.md](vscode-remote://dev-container%2B7b22686f737450617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c7337222c226c6f63616c446f636b6572223a66616c73652c2273657474696e6773223a7b22636f6e74657874223a226465736b746f702d6c696e7578227d2c22636f6e66696746696c65223a7b22246d6964223a312c22667350617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2265787465726e616c223a2266696c653a2f2f2f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2270617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c22736368656d65223a2266696c65227d7d/workspaces/e-commerce-rails7/.github/prompts/postgresql-optimization.prompt.md).
Optimize admin dashboard revenue aggregations. Run all tests and fix any errors and run rubocop as the last step. Do not commit the code.

--------------------------------

Follow instructions in [playwright-explore-website.prompt.md](vscode-remote://dev-container%2B7b22686f737450617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c7337222c226c6f63616c446f636b6572223a66616c73652c2273657474696e6773223a7b22636f6e74657874223a226465736b746f702d6c696e7578227d2c22636f6e66696746696c65223a7b22246d6964223a312c22667350617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2265787465726e616c223a2266696c653a2f2f2f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2270617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c22736368656d65223a2266696c65227d7d/workspaces/e-commerce-rails7/.github/prompts/playwright-explore-website.prompt.md).
Explore https://shop.cariana.tech/ and create some tests. Run the tests and fix any that are failing. Remember to run rubocop. Do not commit any code produced.

--------------------------------

Follow instructions in [playwright-explore-website.prompt.md](vscode-remote://dev-container%2B7b22686f737450617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c7337222c226c6f63616c446f636b6572223a66616c73652c2273657474696e6773223a7b22636f6e74657874223a226465736b746f702d6c696e7578227d2c22636f6e66696746696c65223a7b22246d6964223a312c22667350617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2265787465726e616c223a2266696c653a2f2f2f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c2270617468223a222f55736572732f616e74686f6e79777261746865722f446f63756d656e74732f50726f6a656374732f452d436f6d6d657263652f652d636f6d6d657263652d7261696c73372f2e646576636f6e7461696e65722f646576636f6e7461696e65722e6a736f6e222c22736368656d65223a2266696c65227d7d/workspaces/e-commerce-rails7/.github/prompts/playwright-explore-website.prompt.md).
Explore https://shop.cariana.tech/ and create some tests. Run the tests and fix any that are failing. Remember to run rubocop. Do not commit any code produced.

--------------------------------

install playwright using "npx playwright install" and fix any errors found.

--------------------------------

Run the playwright tests and fix any failures.

--------------------------------

Analyse the following error and identify the problem.
Then fix the fault and write a test to check for this.
amount was renamed to stock_level so analyse the code to see if amount is used anywhere else.
If so fix it and test it.
Run all ruby tests and and fix any faults.
Finally run rubocop and fix any issues. Do not commit the code.

The error is

23:59:34 web.1  | Started PATCH "/admin/products/18" for 148.252.144.191 at 2025-11-25 23:59:34 +0000
23:59:34 web.1  | Cannot render console from 148.252.144.191! Allowed networks: 54.187.216.72, 127.0.0.0/127.255.255.255, ::1
23:59:34 web.1  | Processing by Admin::ProductsController#update as TURBO_STREAM
23:59:34 web.1  |   Parameters: {"authenticity_token"=>"[FILTERED]", "product"=>{"name"=>"Roven Woven Mat 300g", "description"=>"Roven Woven Mat", "images"=>[""], "price"=>"10000", "stock_level"=>"100", "weight"=>"10000", "length"=>"125", "height"=>"30", "width"=>"30", "category_id"=>"4", "active"=>"1"}, "commit"=>"Update Product", "id"=>"18"}
23:59:34 web.1  |   AdminUser Load (0.5ms)  SELECT "admin_users".* FROM "admin_users" WHERE "admin_users"."id" = $1 ORDER BY "admin_users"."id" ASC LIMIT $2  [["id", 1], ["LIMIT", 1]]
23:59:34 web.1  |   Product Load (0.5ms)  SELECT "products".* FROM "products" WHERE "products"."id" = $1 LIMIT $2  [["id", 18], ["LIMIT", 1]]
23:59:34 web.1  |   ↳ app/controllers/admin/products_controller.rb:80:in `set_admin_product'
23:59:34 web.1  |   CACHE Product Load (0.1ms)  SELECT "products".* FROM "products" WHERE "products"."id" = $1 LIMIT $2  [["id", 18], ["LIMIT", 1]]
23:59:34 web.1  |   ↳ app/controllers/admin/products_controller.rb:46:in `update'
23:59:34 web.1  | Unpermitted parameter: :stock_level. Context: { controller: Admin::ProductsController, action: update, request: #<ActionDispatch::Request:0x00007fee38d95f20>, params: {"_method"=>"patch", "authenticity_token"=>"[FILTERED]", "product"=>{"name"=>"Roven Woven Mat 300g", "description"=>"Roven Woven Mat", "images"=>[""], "price"=>"10000", "stock_level"=>"100", "weight"=>"10000", "length"=>"125", "height"=>"30", "width"=>"30", "category_id"=>"4", "active"=>"1"}, "commit"=>"Update Product", "controller"=>"admin/products", "action"=>"update", "id"=>"18"} }
23:59:34 web.1  | Unpermitted parameter: :stock_level. Context: { controller: Admin::ProductsController, action: update, request: #<ActionDispatch::Request:0x00007fee38d95f20>, params: {"_method"=>"patch", "authenticity_token"=>"[FILTERED]", "product"=>{"name"=>"Roven Woven Mat 300g", "description"=>"Roven Woven Mat", "images"=>[""], "price"=>"10000", "stock_level"=>"100", "weight"=>"10000", "length"=>"125", "height"=>"30", "width"=>"30", "category_id"=>"4", "active"=>"1"}, "commit"=>"Update Product", "controller"=>"admin/products", "action"=>"update", "id"=>"18"} }
23:59:34 web.1  | Unpermitted parameter: :stock_level. Context: { controller: Admin::ProductsController, action: update, request: #<ActionDispatch::Request:0x00007fee38d95f20>, params: {"_method"=>"patch", "authenticity_token"=>"[FILTERED]", "product"=>{"name"=>"Roven Woven Mat 300g", "description"=>"Roven Woven Mat", "images"=>[""], "price"=>"10000", "stock_level"=>"100", "weight"=>"10000", "length"=>"125", "height"=>"30", "width"=>"30", "category_id"=>"4", "active"=>"1"}, "commit"=>"Update Product", "controller"=>"admin/products", "action"=>"update", "id"=>"18"} }
23:59:34 web.1  | Redirected to https://loved-anchovy-on.ngrok-free.app/admin/products/18/edit
23:59:34 web.1  | Completed 302 Found in 14ms (ActiveRecord: 0.7ms | Allocations: 3819)


--------------------------------

VAT is not displayed on the Stripe Checkout screen.
Analyse the Cart and Stripe Checkout setup.
Examine the Cart to Checkout handoff and see how the VAT can be displayed in the Stripe Checkout screen.
Run all tests and fix any errors.
Run rubocop and fix any errors.
Do not commit the code.

--------------------------------

Analyse the product and stock model.
Rename the weight, height, length, and width fields to be shipping_weight, shipping_height, shipping_length, and shipping_width
Update the admin product and stock edit screens to use the new fields and names.
Analyse the validations and make any changes needed.
Analyse the code for any other impacts caused by the name change.

Do not run the playwright tests.
Run all ruby and rails tests and fix any errors.
Run rubocop and fix any errors.
Do not commit the code.

--------------------------------

Add a field to the product and stock table called fiberglass_reinforcement which is true or false and defaults to false.
Add 3 fields to the product and stock table called min_resin_per_m2, max_resin_per_m2, avg_resin_per_m2 which is the number of grams of resin per square meter which defaults to 0.
Add all the fields to the admin product and stock edit screen.

Do not run the playwright tests.
Run all ruby and rails tests and fix any errors.
Run rubocop and fix any errors.
Do not commit the code.

--------------------------------

Analyse the models and schema.rb and update the existing schema-diagram.md

--------------------------------

Fix the layout of the /admin_users/sign_in, /admin_users/password/new and /admin_users/sign_up screens. They are not laid out correctly and have bad formatting.

Do not run the playwright tests.
Run all "bin/rails test" and "bin/rails test:system" and "bin/rails test:all" and fix any errors.
Run rubocop and fix any errors.
Do not commit the code.

--------------------------------

Analyse the exiting code and suggest any improvements to make the database more robust.

--------------------------------

Run "bin/rails test:system" and analyse the reason for the test failure.
Identify a solution and fix the problem.

Do not run the playwright tests.
Run all "bin/rails test" and "bin/rails test:system" and "bin/rails test:all" and fix any errors.
Run rubocop and fix any errors.
Do not commit the code.

--------------------------------

Fix the layout of the /admin_users/sign_in, /admin_users/password/new and /admin_users/sign_up screens. They are not laid out correctly and have bad formatting.

Do not run the playwright tests.
Run all "bin/rails test" and "bin/rails test:system" and "bin/rails test:all" and fix any errors.
Run rubocop and fix any errors.
Do not commit the code.

--------------------------------

[Trying plan mode?]
Analyse the existing codebase and architecture and make a list of suggested improvements.

--------------------------------

Create a implementation plan for the next sprint?

--------------------------------

[Agent Mode]
Create documentation/sprint-plan-01.md

--------------------------------

Create GitHub issues from these tasks

--------------------------------

use the existing /workspaces/e-commerce-rails7/documentation/sprint-plan-01.md and documentation/github-issues-sprint-01.md to create issues in AnthonyWrather/e-commerce-rails7

--------------------------------

Analyse .devcontainer/Dockerfile and add the installation of the GitHub CLI to the docker setup

--------------------------------

Bump rack-session from 2.0.0 to 2.1.1 and Bump rack from 3.0.8 to 3.1.18

Do not run the playwright tests.
Run all "bin/rails test" and "bin/rails test:system" and "bin/rails test:all" and fix any errors.
Run rubocop and fix any errors.
Do not commit the code.

--------------------------------

Follow instructions in suggest-awesome-github-copilot-collections.prompt.md

--------------------------------

Update documentation.

/awesome-copilot create-readme
Follow instructions in suggest-awesome-github-copilot-collections.prompt.md

Follow instructions in [create-readme.prompt.md]

Analyse the models, schema.rb, etc and update the existing schema-diagram.md

Analyze this codebase to generate or update `.github/copilot-instructions.md` and `.github/AGENTS.md` for guiding AI coding agents.

Focus on discovering the essential knowledge that would help an AI agents be immediately productive in this codebase. Consider aspects like:
- The "big picture" architecture that requires reading multiple files to understand - major components, service boundaries, data flows, and the "why" behind structural decisions
- Critical developer workflows (builds, tests, debugging) especially commands that aren't obvious from file inspection alone
- Project-specific conventions and patterns that differ from common practices
- Integration points, external dependencies, and cross-component communication patterns

Source existing AI conventions from `**/{.github/copilot-instructions.md,AGENT.md,AGENTS.md,CLAUDE.md,.cursorrules,.windsurfrules,.clinerules,.cursor/rules/**,.windsurf/rules/**,.clinerules/**,README.md}` (do one glob search).

Guidelines (read more at https://aka.ms/vscode-instructions-docs):
- If `.github/copilot-instructions.md` exists, merge intelligently - preserve valuable content while updating outdated sections
- If `.github/AGENTS.md` exists, merge intelligently - preserve valuable content while updating outdated sections
- Write concise, actionable instructions (~20-50 lines) using markdown structure
- Include specific examples from the codebase when describing patterns
- Avoid generic advice ("write tests", "handle errors") - focus on THIS project's specific approaches
- Document only discoverable patterns, not aspirational practices
- Reference key files/directories that exemplify important patterns

Generate or update `.github/copilot-instructions.md` and `.github/AGENTS.md` for the user, then ask for feedback on any unclear or incomplete sections to iterate.

--------------------------------

Analyse the existing codebase and architecture and make a list of suggested improvements.
Create or update the implementation plan for the next sprint and create documentation.scratch/sprint-plan-02.md
Create the issues in AnthonyWrather/e-commerce-rails7 and create a new kanban board for this sprint.

--------------------------------

Examine the documentation in `documentation/*.md` and analyse the codebase and then update the documentation, then ask for feedback on any unclear or incomplete sections to iterate.

--------------------------------

Coding Agent prompt.

Remember to run rubocop, rails test, rails test:system
Fix any test failures and continue.
Do not let the test coverage drop below 60%

--------------------------------

Analyse the existing codebase and architecture.
Analyse issue [#186](https://github.com/AnthonyWrather/e-commerce-rails7/issues/186)
Create or update the implementation plan for the next sprint and create documentation.scratch/sprint-plan-user-accounts.md
Create the issues in AnthonyWrather/e-commerce-rails7
Add the issues to the e-commerce-rails7 Kanban Board (https://github.com/users/AnthonyWrather/projects/3/views/2)

--------------------------------

Coding Agent prompt.

Examine the sprint plan document "documentation.scratch/sprint-plan-user-accounts.md"
Remember to run "rubocop", "rails test", "rails test:system"
Fix any test failures and continue.
Update any relevant documentation.
Do not let the test coverage drop below 60% for "rails test"
Do not let the test coverage drop below 60% for "rails test:system"

--------------------------------

Examine the sprint plan document "documentation.scratch/sprint-plan-user-accounts.md"
Remember to run "rubocop", "rails test", "rails test:system"
Fix any test failures and continue.
Update any relevant documentation.

--------------------------------

gh auth login
gh auth refresh
gh auth refresh -s read:project -s project

gh issue list

--------------------------------

Analyse the existing codebase and architecture.
Analyse issue [#176](https://github.com/AnthonyWrather/e-commerce-rails7/issues/176)
Create or update the implementation plan for the next sprint and create documentation.scratch/sprint-plan-add-a-chat-feature.md
Create the issues in AnthonyWrather/e-commerce-rails7
Add the issues to the e-commerce-rails7 Kanban Board (https://github.com/users/AnthonyWrather/projects/3/views/2)

--------------------------------

Examine the sprint plan document "documentation.scratch/sprint-plan-add-a-chat-feature.md"
Remember to run "rubocop", "rails test", "rails test:system"
Fix any test failures and continue.
Update any relevant documentation.

--------------------------------

Please analyse
Create an issue in AnthonyWrather/e-commerce-rails7
Add any labels needed
Add the issue to the e-commerce-rails7 Kanban Board (https://github.com/users/AnthonyWrather/projects/3/views/2)

--------------------------------


--------------------------------


--------------------------------


--------------------------------


--------------------------------


--------------------------------


--------------------------------


--------------------------------


--------------------------------


--------------------------------


--------------------------------



