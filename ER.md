# Entity-Relationship Diagrams (Mermaid)

Now, let me create comprehensive ER diagrams for this system:
erDiagram
    %% Core User and Authentication
    users ||--o{ teachers : "is_a"
    users ||--o{ admins : "is_a"
    users {
        uuid id PK
        string phone_number UK
        string otp_hash
        timestamp otp_expires_at
        timestamp last_login
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    %% Schools and Multi-Tenancy
    schools ||--o{ school_teachers : "has_many"
    schools ||--o{ students : "has_many"
    schools ||--o{ classes : "has_many"
    schools ||--o{ attendance_records : "has_many"
    schools ||--o{ fee_collections : "has_many"
    schools ||--o{ holidays : "has_many"
    schools ||--o{ school_config : "has_one"
    schools {
        uuid id PK
        string name
        string code UK
        string address
        string contact_phone
        string contact_email
        string subscription_tier
        timestamp subscription_expires_at
        json settings
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    %% Teachers (can belong to multiple schools)
    teachers ||--o{ school_teachers : "belongs_to_many"
    teachers ||--o{ attendance_records : "records"
    teachers ||--o{ fee_collections : "collects"
    teachers {
        uuid id PK
        uuid user_id FK
        string first_name
        string last_name
        string employee_id UK
        string photo_url
        timestamp created_at
        timestamp updated_at
    }

    %% Many-to-Many: Schools and Teachers
    school_teachers {
        uuid id PK
        uuid school_id FK
        uuid teacher_id FK
        enum role
        json assigned_classes
        boolean is_active
        timestamp assigned_at
        timestamp created_at
        timestamp updated_at
    }

    %% Admins
    admins ||--|| schools : "manages"
    admins {
        uuid id PK
        uuid user_id FK
        uuid school_id FK
        string first_name
        string last_name
        timestamp created_at
        timestamp updated_at
    }

    %% Classes
    classes ||--o{ students : "has_many"
    classes ||--o{ attendance_records : "has_many"
    classes {
        uuid id PK
        uuid school_id FK
        string name
        string grade_level
        string section
        integer academic_year
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    %% Students
    students ||--o{ attendance_records : "has_many"
    students ||--o{ fee_collections : "has_many"
    students ||--o{ student_fee_config : "has_one"
    students ||--o{ scholarships : "has_many"
    students {
        uuid id PK
        uuid school_id FK
        uuid class_id FK
        string student_id UK
        string first_name
        string last_name
        date date_of_birth
        string photo_url
        string parent_phone
        string parent_email
        string address
        boolean is_active
        timestamp enrolled_at
        timestamp created_at
        timestamp updated_at
    }

    %% Student Fee Configuration
    student_fee_config {
        uuid id PK
        uuid student_id FK
        decimal canteen_daily_fee
        decimal transport_daily_fee
        string transport_location
        boolean canteen_enabled
        boolean transport_enabled
        timestamp created_at
        timestamp updated_at
    }

    %% Scholarships and Waivers
    scholarships {
        uuid id PK
        uuid student_id FK
        enum type
        decimal discount_percentage
        decimal fixed_discount
        string description
        date valid_from
        date valid_until
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    %% Attendance Records
    attendance_records {
        uuid id PK
        uuid school_id FK
        uuid student_id FK
        uuid class_id FK
        uuid recorded_by FK
        date attendance_date
        enum status
        string notes
        timestamp recorded_at
        timestamp synced_at
        enum sync_status
        timestamp created_at
        timestamp updated_at
    }

    %% Fee Collections
    fee_collections {
        uuid id PK
        uuid school_id FK
        uuid student_id FK
        uuid collected_by FK
        enum fee_type
        decimal amount_paid
        date payment_date
        date coverage_start_date
        date coverage_end_date
        string payment_method
        string receipt_number
        string notes
        timestamp collected_at
        timestamp synced_at
        enum sync_status
        timestamp created_at
        timestamp updated_at
    }

    %% Holidays
    holidays {
        uuid id PK
        uuid school_id FK
        date holiday_date
        string name
        string description
        boolean is_recurring
        timestamp created_at
        timestamp updated_at
    }

    %% School Configuration
    school_config {
        uuid id PK
        uuid school_id FK
        json theme_settings
        json fee_settings
        json notification_settings
        json academic_calendar
        timestamp created_at
        timestamp updated_at
    }

    %% Sync Metadata (for offline-first)
    sync_log ||--|| schools : "belongs_to"
    sync_log {
        uuid id PK
        uuid school_id FK
        string entity_type
        uuid entity_id
        enum operation
        timestamp timestamp
        enum sync_status
        json conflict_data
        timestamp created_at
    }

    %% Audit Log
    audit_log ||--|| users : "performed_by"
    audit_log ||--|| schools : "belongs_to"
    audit_log {
        uuid id PK
        uuid school_id FK
        uuid user_id FK
        string entity_type
        uuid entity_id
        enum action
        json old_values
        json new_values
        string ip_address
        timestamp created_at
    }
    
I've created a comprehensive system design and architecture document along with a complete Entity-Relationship diagram for your School Management SaaS application. Here are the key highlights:

## Key Architectural Decisions:

1. **Multi-School Teacher Support**: Implemented through a `school_teachers` junction table that allows teachers to be associated with multiple schools while maintaining proper role-based access per school.

2. **Offline-First Architecture**: Uses SQLite for local storage with a robust synchronization engine that handles conflicts using last-write-wins strategy with timestamp tracking.

3. **Multi-Tenancy**: School-based tenant isolation with Row-Level Security (RLS) policies ensuring complete data separation while allowing cross-tenant teacher associations.

4. **Flexible Fee Configuration**: Each student can have custom fee configurations for both canteen and transportation, with support for scholarships and waivers.

5. **Comprehensive Sync Strategy**: Tracks sync status for critical entities (attendance, fee collections) with conflict resolution and audit logging.

## ER Diagram Highlights:

- **Users → Teachers/Admins**: Inheritance relationship where users can be either teachers or admins
- **Schools ↔ Teachers**: Many-to-many relationship allowing teachers to work across multiple schools
- **Students**: Single school association with flexible fee configurations
- **Attendance & Fee Collections**: Linked to specific schools with sync tracking
- **Audit & Sync Logs**: Complete tracking for compliance and offline synchronization
