# GitHub Copilot Development Environment Setup

This workflow provides a consistent development environment for GitHub Copilot agents to perform testing and bug fixing.

## Overview

The `.github/workflows/copilot-setup-steps.yml` workflow configures a complete development environment that mirrors the production CI setup, ensuring that Copilot agents have access to all necessary services and dependencies.

## Services Provided

### PostgreSQL Database
- **Version**: PostgreSQL 15
- **Port**: 5432
- **Database**: `e_commerce_rails7_test`
- **Credentials**: postgres/postgres
- **Features**: Health checks, superuser permissions

### Redis Cache
- **Version**: Redis 7 (Alpine)
- **Port**: 6379
- **Purpose**: Action Cable (WebSocket) support for real-time chat
- **Features**: Health checks enabled

### Runtime Environment
- **Ruby**: 3.2.3 with bundler cache
- **Node.js**: 20.x with Yarn cache
- **System Libraries**: libvips (image processing), libpq-dev (PostgreSQL)

## How to Use

### Manual Trigger

The workflow is designed to be triggered manually via GitHub Actions:

1. Navigate to **Actions** tab in the GitHub repository
2. Select **Copilot Development Environment Setup** workflow
3. Click **Run workflow**
4. Choose setup type:
   - **full**: Complete setup with linting, security scan, and all tests
   - **minimal**: Basic environment setup only

### Setup Types

#### Minimal Setup
- Checks out code
- Installs Ruby, Node.js, and system dependencies
- Installs Ruby gems and JavaScript packages
- Compiles TypeScript/JavaScript assets
- Prepares the database
- Verifies the environment

#### Full Setup
Includes all minimal setup steps plus:
- RuboCop linting checks
- Brakeman security scanning
- Unit and integration tests
- System tests (Capybara)
- Test artifact uploads on failure

## Environment Variables

The workflow uses the following environment variables:

```yaml
RAILS_ENV: test
DATABASE_URL: postgres://postgres:postgres@localhost:5432/e_commerce_rails7_test
REDIS_URL: redis://localhost:6379/1
RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
NODE_ENV: test
```

**Important**: Ensure `RAILS_MASTER_KEY` is set in the repository secrets for decrypting Rails credentials.

## What Gets Verified

The workflow verifies the following:

1. **Ruby Environment**
   - Ruby version (3.2.3)
   - Bundler installation
   - Gem dependencies

2. **Node.js Environment**
   - Node.js version (20.x)
   - Yarn version
   - JavaScript dependencies

3. **Database**
   - PostgreSQL connection
   - Database creation and migration
   - Superuser permissions

4. **Redis**
   - Redis server connectivity
   - Version check

5. **Asset Compilation**
   - TypeScript/JavaScript build success
   - Output files in `app/assets/builds/`

6. **Rails Application**
   - Rails version and configuration
   - Database schema
   - Environment settings

## Troubleshooting

### RAILS_MASTER_KEY Not Set

If you see errors about missing credentials:

```bash
Missing encryption key to decrypt file with.
```

Solution: Add `RAILS_MASTER_KEY` to repository secrets:
1. Go to Settings → Secrets and variables → Actions
2. Add new repository secret: `RAILS_MASTER_KEY`
3. Copy the value from `config/master.key`

### Database Connection Failures

If PostgreSQL connection fails:
- Check that the service is healthy (workflow shows health check status)
- Verify `DATABASE_URL` environment variable
- Ensure port 5432 is not blocked

### Asset Compilation Errors

If JavaScript/TypeScript build fails:
- Check TypeScript syntax errors in the logs
- Verify all dependencies are installed
- Review `package.json` for correct scripts

### Test Failures

If tests fail during full setup:
- Review the test output in the workflow logs
- Check uploaded artifacts for screenshots (system tests)
- Review coverage reports in artifacts

## Integration with Copilot Agents

This workflow is specifically designed for GitHub Copilot agents to:

1. **Understand the Environment**: Agents can reference this workflow to know exactly what services are available
2. **Reproduce Issues**: The same environment used in CI is available for debugging
3. **Run Tests**: Agents can verify their fixes work in a production-like environment
4. **Access Services**: PostgreSQL and Redis are configured and ready to use

## Differences from CI Workflow

While this workflow mirrors the CI setup, there are some differences:

| Feature | CI Workflow | Copilot Setup |
|---------|-------------|---------------|
| Trigger | Automatic (on push/PR) | Manual (workflow_dispatch) |
| Purpose | Continuous integration | Development environment |
| Test Execution | Always runs | Optional (full mode) |
| Artifact Upload | On failure | On failure (full mode) |
| Redis Service | Not included | Included for chat features |

## File Structure

```
.github/
└── workflows/
    ├── ci.yml                      # Production CI pipeline
    └── copilot-setup-steps.yml     # Copilot development environment
```

## Related Documentation

- [CI Workflow](.github/workflows/ci.yml) - Production CI configuration
- [Dev Container](.devcontainer/docker-compose.yml) - Local development setup
- [Database Config](config/database.yml) - Database configuration
- [Cable Config](config/cable.yml) - Action Cable/Redis configuration

## Future Enhancements

Potential improvements for this workflow:

- [ ] Add caching for compiled assets
- [ ] Support for different Ruby/Node versions
- [ ] Integration with dev container configuration
- [ ] Pre-seeding test data
- [ ] Performance benchmarking
- [ ] Playwright test execution

## Support

For issues or questions about this workflow:
- Open an issue in the repository
- Check existing CI workflow logs for comparison
- Review the [README](../README.md) for project setup details
