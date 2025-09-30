import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'school_fee_app.db';
  static const int _databaseVersion = 2;

  // Table names
  static const String tableUsers = 'users';
  static const String tableSchools = 'schools';
  static const String tableTeachers = 'teachers';
  static const String tableStudents = 'students';
  static const String tableClasses = 'classes';
  static const String tableSchoolTeachers = 'school_teachers';
  static const String tableAttendanceRecords = 'attendance_records';
  static const String tableFeeCollections = 'fee_collections';
  static const String tableStudentFeeConfig = 'student_fee_config';
  static const String tableScholarships = 'scholarships';
  static const String tableHolidays = 'holidays';
  static const String tableSyncLog = 'sync_log';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute(
        '''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        phone_number TEXT UNIQUE NOT NULL,
        otp_hash TEXT,
        otp_expires_at INTEGER,
        last_login INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create Schools table
    await db.execute(
        '''
      CREATE TABLE $tableSchools (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        address TEXT,
        contact_phone TEXT,
        contact_email TEXT,
        subscription_tier TEXT NOT NULL,
        subscription_expires_at INTEGER,
        settings TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create Teachers table
    await db.execute(
        '''
      CREATE TABLE $tableTeachers (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        employee_id TEXT UNIQUE,
        photo_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableUsers (id)
      )
    ''');

    // Create Classes table
    await db.execute(
        '''
      CREATE TABLE $tableClasses (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        name TEXT NOT NULL,
        grade_level TEXT NOT NULL,
        section TEXT NOT NULL,
        academic_year INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (school_id) REFERENCES $tableSchools (id)
      )
    ''');

    // Create Students table
    await db.execute(
        '''
      CREATE TABLE $tableStudents (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        student_id TEXT UNIQUE NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        date_of_birth INTEGER,
        photo_url TEXT,
        parent_phone TEXT,
        parent_email TEXT,
        address TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        enrolled_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (school_id) REFERENCES $tableSchools (id),
        FOREIGN KEY (class_id) REFERENCES $tableClasses (id)
      )
    ''');

    // Create School Teachers junction table
    await db.execute(
        '''
      CREATE TABLE $tableSchoolTeachers (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        role TEXT NOT NULL,
        assigned_classes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        assigned_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (school_id) REFERENCES $tableSchools (id),
        FOREIGN KEY (teacher_id) REFERENCES $tableTeachers (id)
      )
    ''');

    // Create Attendance Records table
    await db.execute(
        '''
      CREATE TABLE $tableAttendanceRecords (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        recorded_by TEXT NOT NULL,
        attendance_date INTEGER NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        recorded_at INTEGER NOT NULL,
        synced_at INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (school_id) REFERENCES $tableSchools (id),
        FOREIGN KEY (student_id) REFERENCES $tableStudents (id),
        FOREIGN KEY (class_id) REFERENCES $tableClasses (id),
        FOREIGN KEY (recorded_by) REFERENCES $tableTeachers (id)
      )
    ''');

    // Create Fee Collections table
    await db.execute(
        '''
      CREATE TABLE $tableFeeCollections (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        collected_by TEXT NOT NULL,
        fee_type TEXT NOT NULL,
        amount_paid REAL NOT NULL,
        payment_date INTEGER NOT NULL,
        coverage_start_date INTEGER NOT NULL,
        coverage_end_date INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        receipt_number TEXT NOT NULL,
        notes TEXT,
        collected_at INTEGER NOT NULL,
        synced_at INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (school_id) REFERENCES $tableSchools (id),
        FOREIGN KEY (student_id) REFERENCES $tableStudents (id),
        FOREIGN KEY (collected_by) REFERENCES $tableTeachers (id)
      )
    ''');

    // Create Student Fee Config table
    await db.execute(
        '''
      CREATE TABLE $tableStudentFeeConfig (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        canteen_daily_fee REAL NOT NULL DEFAULT 0,
        transport_daily_fee REAL NOT NULL DEFAULT 0,
        transport_location TEXT,
        canteen_enabled INTEGER NOT NULL DEFAULT 1,
        transport_enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES $tableStudents (id)
      )
    ''');

    // Create Scholarships table
    await db.execute(
        '''
      CREATE TABLE $tableScholarships (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        type TEXT NOT NULL,
        discount_percentage REAL,
        fixed_discount REAL,
        description TEXT NOT NULL,
        valid_from INTEGER NOT NULL,
        valid_until INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES $tableStudents (id)
      )
    ''');

    // Create Holidays table
    await db.execute(
        '''
      CREATE TABLE $tableHolidays (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        holiday_date INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (school_id) REFERENCES $tableSchools (id)
      )
    ''');

    // Create Sync Log table
    await db.execute(
        '''
      CREATE TABLE $tableSyncLog (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        sync_status TEXT NOT NULL,
        conflict_data TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (school_id) REFERENCES $tableSchools (id)
      )
    ''');

    // Create indexes for better performance
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    // Users indexes
    await db.execute(
        'CREATE INDEX idx_users_phone_number ON $tableUsers (phone_number)');
    await db
        .execute('CREATE INDEX idx_users_is_active ON $tableUsers (is_active)');

    // Schools indexes
    await db.execute('CREATE INDEX idx_schools_code ON $tableSchools (code)');
    await db.execute(
        'CREATE INDEX idx_schools_is_active ON $tableSchools (is_active)');

    // Teachers indexes
    await db.execute(
        'CREATE INDEX idx_teachers_user_id ON $tableTeachers (user_id)');
    await db.execute(
        'CREATE INDEX idx_teachers_employee_id ON $tableTeachers (employee_id)');

    // Students indexes
    await db.execute(
        'CREATE INDEX idx_students_school_id ON $tableStudents (school_id)');
    await db.execute(
        'CREATE INDEX idx_students_class_id ON $tableStudents (class_id)');
    await db.execute(
        'CREATE INDEX idx_students_student_id ON $tableStudents (student_id)');
    await db.execute(
        'CREATE INDEX idx_students_is_active ON $tableStudents (is_active)');

    // Attendance Records indexes
    await db.execute(
        'CREATE INDEX idx_attendance_school_id ON $tableAttendanceRecords (school_id)');
    await db.execute(
        'CREATE INDEX idx_attendance_student_id ON $tableAttendanceRecords (student_id)');
    await db.execute(
        'CREATE INDEX idx_attendance_date ON $tableAttendanceRecords (attendance_date)');
    await db.execute(
        'CREATE INDEX idx_attendance_sync_status ON $tableAttendanceRecords (sync_status)');

    // Fee Collections indexes
    await db.execute(
        'CREATE INDEX idx_fee_collections_school_id ON $tableFeeCollections (school_id)');
    await db.execute(
        'CREATE INDEX idx_fee_collections_student_id ON $tableFeeCollections (student_id)');
    await db.execute(
        'CREATE INDEX idx_fee_collections_payment_date ON $tableFeeCollections (payment_date)');
    await db.execute(
        'CREATE INDEX idx_fee_collections_sync_status ON $tableFeeCollections (sync_status)');

    // Sync Log indexes
    await db.execute(
        'CREATE INDEX idx_sync_log_school_id ON $tableSyncLog (school_id)');
    await db.execute(
        'CREATE INDEX idx_sync_log_entity_type ON $tableSyncLog (entity_type)');
    await db.execute(
        'CREATE INDEX idx_sync_log_sync_status ON $tableSyncLog (sync_status)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Database upgrade triggered: $oldVersion → $newVersion');

    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Version 1 to 2: Fix schools table constraints to match Supabase
      if (oldVersion < 2) {
        print('🔄 Upgrading database from version $oldVersion to $newVersion');
        print('🔄 Fixing schools table constraints to match Supabase schema');

        // Drop and recreate schools table with correct nullable constraints
        await db.execute('DROP TABLE IF EXISTS $tableSchools');

        // Recreate schools table with correct schema
        await db.execute(
            '''
          CREATE TABLE $tableSchools (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            code TEXT UNIQUE NOT NULL,
            address TEXT,
            contact_phone TEXT,
            contact_email TEXT,
            subscription_tier TEXT NOT NULL,
            subscription_expires_at INTEGER,
            settings TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Recreate indexes
        await db
            .execute('CREATE INDEX idx_schools_code ON $tableSchools (code)');
        await db.execute(
            'CREATE INDEX idx_schools_is_active ON $tableSchools (is_active)');

        print('✅ Database upgraded successfully');
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    final tables = [
      tableSyncLog,
      tableHolidays,
      tableScholarships,
      tableStudentFeeConfig,
      tableFeeCollections,
      tableAttendanceRecords,
      tableSchoolTeachers,
      tableStudents,
      tableClasses,
      tableTeachers,
      tableSchools,
      tableUsers,
    ];

    for (final table in tables) {
      await db.delete(table);
    }
  }
}
