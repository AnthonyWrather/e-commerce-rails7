---
description: 'Create Epic architecture specification'
mode: 'agent'
---

# Epic Architecture Specification Generator

Generate a comprehensive architecture document for an Epic based on the Epic PRD.

## Prerequisites

Before generating this architecture spec, ensure:

- ✅ Epic PRD exists: `/docs/ways-of-work/plan/{epic}/epic.md`
- ✅ Epic scope and requirements are well-defined
- ✅ Technical constraints and business requirements are documented

## Process

### 1. Epic Context

Use `#codebase` to read:

- Epic PRD: `/docs/ways-of-work/plan/{epic}/epic.md`

Understand:

- Business requirements and goals
- User personas and use cases
- Success metrics and constraints
- Scale and performance requirements

### 2. Repository Analysis

Use `#search` and `#codebase` to:

- Review current system architecture
- Identify existing patterns and standards
- Locate relevant components for reuse
- Understand deployment infrastructure

### 3. Architecture Generation

Create `/docs/ways-of-work/plan/{epic}/arch.md` with:

## Architecture Specification: {Epic Name}

### Executive Summary

**Epic**: [{Epic Name}](/docs/ways-of-work/plan/{epic}/epic.md)

**Architecture Overview**: High-level description of the proposed system architecture for this Epic.

**Key Design Decisions**: Top 3-5 critical architectural decisions.

**Technology Stack**: Primary technologies chosen for this Epic.

---

### 1. System Overview

#### Business Context

Brief summary of the Epic and its business value from the PRD.

#### Architectural Goals

What the architecture aims to achieve:

- **Scalability**: Support {X} concurrent users, {Y} requests/sec
- **Reliability**: {Z}% uptime, disaster recovery requirements
- **Maintainability**: Modular design, clear boundaries
- **Performance**: Response times, throughput targets
- **Security**: Compliance requirements, data protection

#### Constraints

Technical and business constraints that shape the architecture:

- **Technical**: Platform limitations, legacy system integration
- **Business**: Budget, timeline, regulatory compliance
- **Operational**: Support team capabilities, deployment windows

---

### 2. Architecture Patterns

#### Overall Architecture Style

Describe the high-level architectural approach:

- **Microservices**: Independent services with clear boundaries
- **Monolith**: Single deployable application
- **Serverless**: Event-driven, function-based
- **Hybrid**: Combination with rationale

**Rationale**: Why this pattern was chosen for this Epic.

#### Key Design Patterns

Patterns to be used across the Epic:

- **API Gateway**: For service aggregation and routing
- **Event Sourcing**: For audit and state management
- **CQRS**: Separate read/write operations
- **Repository Pattern**: For data access abstraction
- **Circuit Breaker**: For resilience

---

### 3. System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Web App   │  │ Mobile App  │  │   Admin UI  │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
└─────────┼─────────────────┼─────────────────┼───────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────┐
│                        API Gateway                           │
│                     (Authentication, Rate Limiting)          │
└─────────┬───────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │   │
│  │    A     │  │    B     │  │    C     │  │    D     │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        ▼             ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Database │  │  Cache   │  │  Queue   │  │  Storage │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

### 4. Component Architecture

#### Component Inventory

List all major components/services in the Epic:

| Component     | Responsibility                      | Technology  | Owner Team |
| ------------- | ----------------------------------- | ----------- | ---------- |
| User Service  | Authentication, user management     | Node.js     | Platform   |
| Order Service | Order processing, fulfillment       | Python      | Commerce   |
| Payment API   | Payment processing                  | Java        | Finance    |
| Notification  | Email, SMS, push notifications      | Serverless  | Platform   |

#### Component: {Component Name}

For each major component:

**Purpose**: What this component does

**Responsibilities**:

- Primary function 1
- Primary function 2

**API Surface**:

- `GET /api/resource` - Get resource by ID
- `POST /api/resource` - Create new resource
- `PUT /api/resource/{id}` - Update resource

**Data Model**:

```
Entity: User
- id: UUID (PK)
- email: String (unique)
- createdAt: DateTime

Entity: Profile
- userId: UUID (FK → User.id)
- name: String
```

**Dependencies**:

- **Internal**: Other components this depends on
- **External**: Third-party services or APIs

**Performance Characteristics**:

- Expected throughput: {X} req/sec
- Latency target: <{Y}ms p95
- Scaling strategy: Horizontal auto-scaling

---

### 5. Data Architecture

#### Data Flow

Describe how data moves through the system:

```
User Input → API Gateway → Service Layer → Database
                             ↓
                        Event Queue → Worker → External Service
```

#### Database Schema

High-level schema design:

- **Primary Database**: PostgreSQL for transactional data
- **Cache Layer**: Redis for session and frequently accessed data
- **Event Store**: Kafka for event sourcing and async processing
- **Analytics DB**: Snowflake for reporting and BI

#### Data Retention & Archival

- **Hot Data**: Last 90 days in primary database
- **Warm Data**: 91-365 days in archival storage
- **Cold Data**: >365 days, encrypted and compressed

---

### 6. Integration Architecture

#### External Integrations

| Service          | Purpose             | Protocol | Authentication |
| ---------------- | ------------------- | -------- | -------------- |
| Stripe API       | Payment processing  | REST     | API Key        |
| SendGrid         | Email delivery      | REST     | API Key        |
| Google Maps API  | Geocoding           | REST     | OAuth 2.0      |
| AWS S3           | File storage        | SDK      | IAM Role       |

#### Event-Driven Architecture

If using events:

```
Service A → [Event: UserRegistered] → Event Bus → Service B
                                                  → Service C
```

**Event Schema Example**:

```json
{
  "eventType": "UserRegistered",
  "timestamp": "2024-01-15T10:30:00Z",
  "userId": "uuid",
  "payload": {
    "email": "user@example.com"
  }
}
```

---

### 7. Security Architecture

#### Authentication & Authorization

- **Authentication Method**: JWT tokens with OAuth 2.0
- **Authorization Model**: Role-Based Access Control (RBAC)
- **Token Expiry**: 1 hour access token, 7 day refresh token
- **Session Management**: Stateless with token validation

#### Data Protection

- **In Transit**: TLS 1.3 for all communications
- **At Rest**: AES-256 encryption for sensitive data
- **Key Management**: AWS KMS for encryption keys
- **Secrets Management**: HashiCorp Vault for credentials

#### Security Boundaries

```
┌─────────────────────────────────────────┐
│  DMZ (Firewall, WAF, DDoS Protection)  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│   Application Layer (Private Subnet)   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    Data Layer (Isolated VPC/Subnet)    │
└─────────────────────────────────────────┘
```

#### Compliance Requirements

- GDPR: Data privacy and right to be forgotten
- PCI-DSS: Payment card data handling
- SOC 2: Security and availability controls

---

### 8. Deployment Architecture

#### Infrastructure

- **Cloud Provider**: AWS / Azure / GCP
- **Container Orchestration**: Kubernetes / ECS
- **CI/CD**: GitHub Actions / Jenkins
- **Infrastructure as Code**: Terraform / CloudFormation

#### Deployment Topology

```
Production Environment
├── Region: US-East-1 (Primary)
│   ├── Availability Zone A
│   │   ├── App Server (Auto-scaling group)
│   │   ├── Database (Primary)
│   │   └── Cache (Primary)
│   └── Availability Zone B
│       ├── App Server (Auto-scaling group)
│       ├── Database (Replica)
│       └── Cache (Replica)
└── Region: US-West-2 (DR)
    └── Full environment replica
```

#### Scalability Strategy

- **Horizontal Scaling**: Auto-scaling groups based on CPU/memory
- **Vertical Scaling**: Database instance size for peak load
- **Caching**: Redis for frequently accessed data
- **CDN**: CloudFront for static assets

---

### 9. Observability & Monitoring

#### Monitoring Strategy

- **APM**: New Relic / Datadog for application performance
- **Logs**: Centralized logging with ELK stack
- **Metrics**: Prometheus + Grafana for metrics
- **Tracing**: Jaeger for distributed tracing

#### Key Metrics

| Metric              | Target    | Alert Threshold |
| ------------------- | --------- | --------------- |
| API Response Time   | <200ms    | >500ms          |
| Error Rate          | <0.1%     | >1%             |
| Database CPU        | <70%      | >85%            |
| Queue Depth         | <1000     | >5000           |

#### Alerting & On-Call

- Critical alerts → PagerDuty
- Warning alerts → Slack
- On-call rotation for production support

---

### 10. Technology Stack

#### Frontend

- **Framework**: React 18 / Vue 3 / Angular
- **State Management**: Redux / Vuex
- **UI Library**: Material UI / Tailwind CSS
- **Build Tool**: Vite / Webpack

#### Backend

- **Language**: Node.js / Python / Java
- **Framework**: Express / FastAPI / Spring Boot
- **API Standard**: REST / GraphQL
- **Testing**: Jest / Pytest / JUnit

#### Data Storage

- **Relational DB**: PostgreSQL 15
- **NoSQL**: MongoDB / DynamoDB
- **Cache**: Redis 7
- **Message Queue**: RabbitMQ / Kafka / SQS

#### DevOps

- **Containerization**: Docker
- **Orchestration**: Kubernetes / Docker Swarm
- **CI/CD**: GitHub Actions / GitLab CI
- **Monitoring**: Prometheus, Grafana, ELK

---

### 11. Development Standards

#### Code Organization

- Monorepo vs Multi-repo strategy
- Directory structure conventions
- Naming conventions

#### API Standards

- RESTful API design guidelines
- Versioning strategy (v1, v2)
- Error response format
- Pagination and filtering

#### Testing Requirements

- Unit test coverage: >80%
- Integration test coverage: Key user flows
- E2E test coverage: Critical paths
- Performance testing: Load and stress tests

---

### 12. Migration Strategy

If transitioning from existing system:

#### Migration Phases

**Phase 1**: Data migration

- Export data from legacy system
- Transform and validate
- Import into new system

**Phase 2**: Parallel run

- Run old and new systems side-by-side
- Compare outputs for consistency
- Gradual traffic shift

**Phase 3**: Cutover

- Final data sync
- DNS/routing update
- Legacy system decommission

---

### 13. Disaster Recovery

#### Backup Strategy

- **Database**: Daily full backup, 5-minute incremental
- **File Storage**: Continuous replication across regions
- **Configuration**: Version controlled in Git

#### Recovery Time Objectives

- **RTO** (Recovery Time Objective): 4 hours
- **RPO** (Recovery Point Objective): 15 minutes
- **Failover**: Automated to DR region

---

### 14. Cost Estimation

#### Infrastructure Costs (Monthly)

| Component         | Cost      | Notes                    |
| ----------------- | --------- | ------------------------ |
| Compute           | $5,000    | EC2/ECS instances        |
| Database          | $2,000    | RDS PostgreSQL           |
| Storage           | $500      | S3 storage               |
| Data Transfer     | $1,000    | Egress charges           |
| **Total**         | **$8,500**|                          |

#### Scaling Projections

As user base grows:

- Year 1: $8,500/month
- Year 2: $15,000/month (2x growth)
- Year 3: $30,000/month (further 2x growth)

---

### 15. Risks & Trade-offs

| Decision                | Benefit                  | Risk                    | Mitigation                |
| ----------------------- | ------------------------ | ----------------------- | ------------------------- |
| Microservices           | Independent scaling      | Operational complexity  | Service mesh, observability |
| Serverless functions    | Cost efficiency          | Cold start latency      | Provisioned concurrency   |
| NoSQL for scalability   | High throughput          | Complex queries         | Hybrid approach with SQL  |

---

### 16. Future Considerations

Features or capabilities deferred for future phases:

- Multi-region active-active deployment
- ML-based personalization engine
- Real-time analytics dashboard
- GraphQL API layer

---

**References**:

- Epic PRD: `/docs/ways-of-work/plan/{epic}/epic.md`
- Tech Stack Documentation: [Internal Wiki]
- Architecture Decision Records: `/docs/adr/`

---

**Revision History**:

| Version | Date       | Author | Changes                       |
| ------- | ---------- | ------ | ----------------------------- |
| 1.0     | YYYY-MM-DD | Name   | Initial architecture draft    |

### 4. Validation

Ensure the architecture spec:

- ✅ Addresses all Epic requirements and constraints
- ✅ Includes detailed component and data architecture
- ✅ Defines clear technology choices with rationale
- ✅ Covers security, scalability, and reliability
- ✅ Provides deployment and monitoring strategy

## T-Shirt Sizing

Estimate complexity and effort:

- **XS**: 1-2 weeks, 1 developer
- **S**: 2-4 weeks, 1-2 developers
- **M**: 1-2 months, 2-3 developers
- **L**: 2-4 months, 3-5 developers
- **XL**: 4+ months, 5+ developers, multiple teams

## Invocation

```
@workspace #breakdown-epic-arch

Context:
- Epic: {epic-name}
- Epic PRD: /docs/ways-of-work/plan/{epic}/epic.md
```

## Output

Creates `/docs/ways-of-work/plan/{epic}/arch.md` with a comprehensive architecture specification ready for feature breakdown and implementation.
