# Uptime Monitoring Setup Guide

**Last Updated**: November 30, 2025
**Status**: Configuration guide for external uptime monitoring

## Overview

This document describes how to set up external uptime monitoring for the E-Commerce Rails 7 application using UptimeRobot. It covers endpoint monitoring, alert configuration, SSL certificate monitoring, and response time tracking.

## Health Check Endpoint

The application exposes a built-in health check endpoint provided by Rails:

```
GET /up
```

### Endpoint Details

| Property | Value |
|----------|-------|
| Path | `/up` |
| Method | `GET` |
| Response (healthy) | HTTP 200 |
| Response (unhealthy) | HTTP 500 |
| Controller | `Rails::HealthController#show` |
| Route name | `rails_health_check` |

### What It Checks

The Rails health check endpoint returns:
- **200 OK** - Application boots successfully with no exceptions
- **500 Internal Server Error** - Application has boot-time exceptions

This endpoint is designed to be used by:
- Load balancers
- Uptime monitors
- Container orchestration health checks
- Render deployment health checks (already configured in `render.yaml`)

## Production Endpoints

| Environment | Domain | Health Check URL |
|-------------|--------|------------------|
| Production | `shop.cariana.tech` | `https://shop.cariana.tech/up` |
| Test | `test.cariana.tech` | `https://test.cariana.tech/up` |

## UptimeRobot Configuration

### Step 1: Sign Up for UptimeRobot

1. Go to [UptimeRobot](https://uptimerobot.com/)
2. Sign up for a free account (or use an existing account)
3. The free tier includes:
   - 50 monitors
   - 5-minute check intervals
   - Email notifications
   - SSL monitoring

### Step 2: Configure Health Check Monitor

Create a monitor for the `/up` endpoint:

1. Click **"+ Add New Monitor"**
2. Configure the monitor with these settings:

| Setting | Value |
|---------|-------|
| Monitor Type | HTTP(s) |
| Friendly Name | `E-Commerce Rails 7 - Production` |
| URL | `https://shop.cariana.tech/up` |
| Monitoring Interval | 5 minutes (free tier) |
| HTTP Method | GET |
| HTTP Status Codes | 200 |

3. Click **"Create Monitor"**

### Step 3: Configure Test Environment Monitor (Optional)

Repeat Step 2 for the test environment:

| Setting | Value |
|---------|-------|
| Friendly Name | `E-Commerce Rails 7 - Test` |
| URL | `https://test.cariana.tech/up` |

### Step 4: Configure Alert Contacts

1. Go to **"My Settings"** → **"Alert Contacts"**
2. Click **"+ Add Alert Contact"**
3. Configure alert contacts:

#### Email Alert

| Setting | Value |
|---------|-------|
| Contact Type | Email |
| Email Address | Your email address |
| Friendly Name | `Admin Email` |

#### Slack Integration (Optional)

| Setting | Value |
|---------|-------|
| Contact Type | Slack |
| Webhook URL | Your Slack webhook URL |
| Channel | `#alerts` or preferred channel |

### Step 5: Configure Alert Timing

For downtime alerts, configure the notification timing:

| Setting | Recommended Value |
|---------|-------------------|
| Alert when down for | 5 minutes |
| Re-notify every | 30 minutes |
| Alert when back up | Yes |

> **Note**: The free tier checks every 5 minutes, so a 5-minute downtime threshold will alert on the first failed check.

### Step 6: Configure Response Time Tracking

UptimeRobot automatically tracks response times for HTTP(s) monitors:

1. Go to your monitor's dashboard
2. View the **"Response Time"** tab
3. Configure alerts for slow response times:

| Metric | Recommended Threshold |
|--------|----------------------|
| Response Time Alert | > 2000ms (2 seconds) |

### Step 7: Configure SSL Certificate Monitoring

1. Click **"+ Add New Monitor"**
2. Configure SSL monitor:

| Setting | Value |
|---------|-------|
| Monitor Type | SSL Certificate |
| Friendly Name | `E-Commerce SSL - Production` |
| URL | `shop.cariana.tech` |
| Alert before expiry | 14 days |

3. Repeat for test environment if needed

## Monitor Summary

After configuration, you should have these monitors:

| Monitor | Type | URL/Domain |
|---------|------|------------|
| Production Health | HTTP(s) | `https://shop.cariana.tech/up` |
| Test Health | HTTP(s) | `https://test.cariana.tech/up` |
| Production SSL | SSL Certificate | `shop.cariana.tech` |

## Render Integration

The application is already configured to use the `/up` endpoint for Render's health checks:

```yaml
# render.yaml (excerpt)
services:
  - type: web
    name: e-commerce-rails7-prod
    healthCheckPath: /up
```

This means:
- Render checks the health endpoint during deployments
- Failed health checks prevent bad deployments
- Zero-downtime deployments rely on this endpoint

## Testing the Health Check

### Using cURL

```bash
# Test Production
curl -I https://shop.cariana.tech/up

# Test locally (development)
curl -I http://localhost:3000/up
```

Expected response for a healthy application:

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
```

### Using Rails Console

```bash
# Verify route exists
bin/rails routes | grep health
# Output: rails_health_check GET /up(.:format) rails/health#show
```

## Troubleshooting

### Monitor Shows Down but App Works

1. **SSL Issues**: Ensure SSL certificate is valid
2. **Firewall Rules**: Check if UptimeRobot IPs are blocked
3. **Rate Limiting**: Verify Rack::Attack isn't blocking monitoring IPs
4. **DNS Issues**: Check DNS propagation

### UptimeRobot IP Addresses

If you need to whitelist UptimeRobot IPs, they publish their list at:
[https://uptimerobot.com/inc/files/ips/IPv4.txt](https://uptimerobot.com/inc/files/ips/IPv4.txt)

### High Response Times

If response times are consistently high:

1. Check server resources (CPU, memory)
2. Review database query performance
3. Check for cold start issues (serverless)
4. Enable caching if not already configured

### False Positives

To reduce false positives:

1. Increase check interval
2. Use keyword monitoring (check for specific content)
3. Configure multi-location monitoring (paid feature)

## Best Practices

### Monitor Multiple Endpoints

Consider monitoring additional critical endpoints:

| Endpoint | Purpose |
|----------|---------|
| `/up` | Basic health check |
| `/` | Homepage loads |
| `/products/{id}` | Product pages work |
| `/cart` | Cart functionality |

### Set Up Status Page

Consider setting up a public status page:

1. UptimeRobot offers free status pages
2. Go to **"Status Pages"** → **"Add Status Page"**
3. Add your monitors to the status page
4. Share URL with stakeholders

### Dashboard Monitoring

Create a dashboard with key metrics:

- Uptime percentage (target: 99.9%)
- Average response time
- SSL certificate expiry dates
- Recent incidents

## Integration with Other Monitoring

### Error Tracking

This uptime monitoring complements error tracking:

| Tool | Purpose |
|------|---------|
| UptimeRobot | External availability monitoring |
| Honeybadger | Exception tracking and error monitoring |
| Rails logs | Detailed application logs |

### Complete Monitoring Stack

For comprehensive monitoring, consider:

1. **Uptime**: UptimeRobot (external)
2. **Errors**: Honeybadger (exceptions)
3. **Performance**: Scout APM or New Relic
4. **Logs**: Papertrail or Loggly
5. **Infrastructure**: Render dashboard

## Costs

| Feature | UptimeRobot Free | UptimeRobot Paid |
|---------|------------------|------------------|
| Monitors | 50 | Unlimited |
| Check Interval | 5 minutes | 1 minute |
| SMS Alerts | ❌ | ✅ |
| Multi-location | Limited | ✅ |
| Price | $0/month | From $7/month |

The free tier is sufficient for most small to medium applications.

## Checklist

Use this checklist to verify your uptime monitoring setup:

- [ ] UptimeRobot account created
- [ ] Production `/up` endpoint monitor configured
- [ ] Test environment monitor configured (optional)
- [ ] Alert contacts configured (email, Slack, etc.)
- [ ] Alert timing set (5+ minutes downtime)
- [ ] Response time alerts configured (> 2 seconds)
- [ ] SSL certificate monitor configured
- [ ] Status page created (optional)
- [ ] Documentation shared with team

## Related Documentation

- [Codebase Analysis - Monitoring Section](codebase-analysis.md#5-infrastructure--devops)
- [Render Configuration](../render.yaml)
- [Error Tracking Setup](error-tracking.md)

---

**Maintained by**: Infrastructure Team
**Review Schedule**: Quarterly
