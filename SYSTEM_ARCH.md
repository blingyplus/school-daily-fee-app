# School Management System - System Design & Architecture Documentation

## 1. Executive Summary

This document outlines the system design and architecture for a School Management SaaS application focused on attendance tracking and fee collection. The system follows an offline-first architecture with multi-tenancy support, enabling teachers to work across multiple schools while maintaining data isolation and synchronization capabilities.

## 2. System Architecture Overview

### 2.1 High-Level Architecture

The system employs a **three-tier architecture** with an offline-first approach:

1. **Presentation Layer**: Mobile application (iOS/Android) built with Flutter/React Native
2. **Application Layer**: Business logic and synchronization services
3. **Data Layer**: Supabase backend with PostgreSQL and local SQLite databases

### 2.2 Architectural Patterns

- **Offline-First Architecture**: Local SQLite database as primary data store with background synchronization
- **Multi-Tenancy**: School-based tenant isolation with cross-tenant teacher associations
- **Event-Driven Sync**: Conflict resolution using last-write-wins with timestamp tracking
- **Role-Based Access Control (RBAC)**: Admin and Staff roles with school-specific permissions

## 3. System Components

### 3.1 Mobile Application (Client)

**Technology Stack:**
- Framework: Flutter or React Native
- Local Database: SQLite with SQLCipher for encryption
- State Management: Provider/Riverpod (Flutter) or Redux/MobX (React Native)
- Authentication: JWT tokens with secure storage

**Core Modules:**

#### 3.1.1 Authentication Module
- Phone number + OTP authentication
- JWT token management
- Secure credential storage
- Session management

#### 3.1.2 Offline Data Management
- SQLite database operations
- Local caching strategy
- Conflict resolution logic
- Data encryption at rest

#### 3.1.3 Synchronization Engine
- Background sync worker
- Manual sync trigger
- Conflict detection and resolution
- Network state monitoring
- Incremental sync with delta updates

#### 3.1.4 User Interface Modules
- **Staff Dashboard**: Attendance marking, fee collection, student search
- **Admin Dashboard**: School setup, reporting, student management
- **Student Management**: CRUD operations, bulk upload interface
- **Fee Collection**: Payment recording, status tracking, receipt generation
- **Reporting**: Charts, filters, export capabilities
- **Calendar**: Holiday marking, payment deadlines

### 3.2 Backend Services (Supabase)

#### 3.2.1 API Layer
- RESTful APIs for CRUD operations
- Real-time subscriptions for data updates
- File upload/download for bulk operations
- Authentication endpoints (OTP generation/verification)

#### 3.2.2 Database (PostgreSQL)
- Multi-tenant data model
- Row-level security (RLS) policies
- Audit logging tables
- Indexes for performance optimization

#### 3.2.3 Authentication Service
- OTP generation and verification
- JWT token issuance
- User session management
- Phone number verification

#### 3.2.4 Storage Service
- Document storage (student photos, receipts)
- Bulk upload file processing
- CDN for static assets

#### 3.2.5 Edge Functions
- Business logic execution
- Data validation
- Report generation
- Bulk import processing
- Scheduled jobs (e.g., payment reminders)

## 4. Data Architecture

### 4.1 Database Schema Design

#### 4.1.1 Core Entities

**Users Table**
- Stores authentication and profile information
- Links to multiple schools through association tables

**Schools Table**
- Tenant identifier
- School configuration and settings
- Subscription information

**Teachers Table**
- Profile information
- Links to Users table
- Can be associated with multiple schools

**Students Table**
- Student demographics
- School association (single tenant)
- Payment configuration
- Scholarship/waiver status

**Attendance Table**
- Daily attendance records
- School and date-based partitioning
- Sync status tracking

**Fee Collections Table**
- Payment records
- Date range coverage
- Payment type (canteen/transport)
- Sync status tracking

### 4.1.2 Multi-Tenancy Implementation

**School-Teacher Association (Many-to-Many)**
```
school_teachers:
  - school_id (FK to schools)
  - teacher_id (FK to teachers)
  - role (staff/admin)
  - status (active/inactive)
  - assigned_classes[]
```

**Row-Level Security**
- All queries filtered by school context
- Teachers can only access schools they're associated with
- Data isolation at database level

### 4.2 Offline Database (SQLite)

**Schema Mirror Strategy:**
- Mirrors cloud database structure
- Additional columns: `sync_status`, `last_modified`, `local_id`
- Supports multiple school contexts per device

**Sync Metadata Tables:**
```
sync_log:
  - entity_type
  - entity_id
  - operation (insert/update/delete)
  - timestamp
  - sync_status
  - school_id
```

## 5. Synchronization Strategy

### 5.1 Sync Flow

#### Offline → Online (Upload)
1. Detect pending local changes via `sync_status` flag
2. Batch changes by entity type
3. Send to server with timestamp
4. Handle conflicts (last-write-wins)
5. Update local records with server IDs
6. Mark as synced

#### Online → Offline (Download)
1. Request changes since `last_sync_timestamp`
2. Receive delta updates per school
3. Apply changes to local SQLite
4. Update sync timestamp
5. Resolve conflicts (server wins for read operations)

### 5.2 Conflict Resolution

**Strategy: Last-Write-Wins (LWW)**
- Each record has `updated_at` timestamp
- Server compares timestamps on conflict
- Newer timestamp wins
- Conflict logs maintained for audit

**Critical Data Handling:**
- Fee collections: Additive approach (no overwrites)
- Attendance: Allow correction within 24 hours
- Student data: Admin changes take precedence

### 5.3 Multi-School Sync

**Context Switching:**
- User selects active school from associated list
- Sync operations scoped to active school
- Background sync for all associated schools
- Priority given to active school

**Bandwidth Optimization:**
- Incremental sync using timestamps
- Compression for bulk data
- Image optimization and lazy loading
- Sync scheduling (WiFi preferred)

## 6. Security Architecture

### 6.1 Authentication & Authorization

**Authentication Flow:**
1. User enters phone number
2. Backend generates OTP (stored in database with TTL)
3. User enters OTP
4. Backend verifies and issues JWT
5. JWT stored securely on device

**Authorization:**
- JWT contains user_id, school_ids[], current_school_id
- Role-based permissions per school
- API endpoints validate school context
- RLS policies enforce data isolation

### 6.2 Data Security

**At Rest:**
- SQLite database encrypted with SQLCipher
- Sensitive data (payment info) additionally encrypted
- Secure storage for JWT tokens

**In Transit:**
- HTTPS/TLS for all API calls
- Certificate pinning for production
- API key obfuscation

**Multi-Tenancy Security:**
- School ID validation on every request
- No cross-tenant data leakage
- Audit logging for sensitive operations

## 7. Scalability Considerations

### 7.1 Performance Optimization

**Mobile App:**
- Lazy loading for lists
- Pagination (50-100 records per page)
- Image caching and compression
- Background sync workers
- Database indexing (SQLite)

**Backend:**
- Connection pooling
- Query optimization with indexes
- Caching layer (Redis) for frequent reads
- Horizontal scaling for Supabase instances

### 7.2 Data Growth Management

**Archival Strategy:**
- Move old records (>2 years) to archive tables
- On-demand retrieval for historical data
- Local database pruning options

**Partitioning:**
- Attendance table partitioned by school and year
- Fee collections partitioned by school and year

## 8. Monitoring & Observability

### 8.1 Application Monitoring

- Error tracking (Sentry/Firebase Crashlytics)
- Performance monitoring
- User analytics (school adoption, feature usage)
- Sync success/failure rates

### 8.2 Backend Monitoring

- API response times
- Database query performance
- Storage utilization
- Sync queue depths
- Failed authentication attempts

## 9. Deployment Architecture

### 9.1 Backend (Supabase)

**Development Environment:**
- Self-hosted Supabase instance
- Staging database

**Production Environment:**
- Supabase Cloud or self-hosted
- Database backups (daily)
- Point-in-time recovery enabled
- CDN for static assets

### 9.2 Mobile App

**Distribution:**
- iOS: App Store
- Android: Google Play Store
- Support for Android 8.0+ and iOS 13+

**Update Strategy:**
- Semantic versioning
- Forced updates for critical security patches
- Gradual rollout (staged deployment)

## 10. Disaster Recovery

### 10.1 Backup Strategy

**Database:**
- Automated daily backups
- Point-in-time recovery (7 days)
- Geo-replicated backups

**Local Data:**
- Users can export data as CSV/PDF
- Automatic cloud backup option (encrypted)

### 10.2 Recovery Procedures

- Database restore from backup
- Sync conflict resolution post-recovery
- User notification and guidance

## 11. Future Considerations

### 11.1 Scalability Enhancements

- Microservices architecture for independent scaling
- Message queue for async operations
- GraphQL API for optimized data fetching

### 11.2 Feature Expansion

- Parent mobile app (read-only access)
- SMS/Push notifications
- Integration with accounting software
- Advanced analytics with ML insights
- Multi-language support

### 11.3 Monetization Architecture

- Subscription management module
- Payment gateway integration
- Feature flagging for tiered access
- Usage tracking and billing

---
