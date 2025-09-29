class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://your-api-url.com/api/v1';
  static const String supabaseUrl = 'https://your-project.supabase.co';

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // User Endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // School Endpoints
  static const String schools = '/schools';
  static const String schoolDetails = '/schools/{id}';
  static const String schoolTeachers = '/schools/{id}/teachers';
  static const String schoolStudents = '/schools/{id}/students';
  static const String schoolClasses = '/schools/{id}/classes';

  // Teacher Endpoints
  static const String teachers = '/teachers';
  static const String teacherDetails = '/teachers/{id}';
  static const String teacherSchools = '/teachers/{id}/schools';

  // Student Endpoints
  static const String students = '/students';
  static const String studentDetails = '/students/{id}';
  static const String studentFeeConfig = '/students/{id}/fee-config';
  static const String studentScholarships = '/students/{id}/scholarships';

  // Class Endpoints
  static const String classes = '/classes';
  static const String classDetails = '/classes/{id}';
  static const String classStudents = '/classes/{id}/students';

  // Attendance Endpoints
  static const String attendance = '/attendance';
  static const String attendanceByDate = '/attendance/date/{date}';
  static const String attendanceByClass = '/attendance/class/{classId}';
  static const String attendanceByStudent = '/attendance/student/{studentId}';
  static const String markAttendance = '/attendance/mark';

  // Fee Collection Endpoints
  static const String feeCollections = '/fee-collections';
  static const String feeCollectionDetails = '/fee-collections/{id}';
  static const String feeCollectionByDate = '/fee-collections/date/{date}';
  static const String feeCollectionByStudent = '/fee-collections/student/{studentId}';
  static const String recordPayment = '/fee-collections/record';

  // Holiday Endpoints
  static const String holidays = '/holidays';
  static const String holidayDetails = '/holidays/{id}';
  static const String holidaysBySchool = '/holidays/school/{schoolId}';

  // Report Endpoints
  static const String reports = '/reports';
  static const String attendanceReport = '/reports/attendance';
  static const String feeCollectionReport = '/reports/fee-collection';
  static const String financialReport = '/reports/financial';
  static const String defaultersReport = '/reports/defaulters';

  // Sync Endpoints
  static const String sync = '/sync';
  static const String syncStatus = '/sync/status';
  static const String syncUpload = '/sync/upload';
  static const String syncDownload = '/sync/download';

  // File Upload Endpoints
  static const String uploadFile = '/files/upload';
  static const String downloadFile = '/files/download/{id}';
  static const String deleteFile = '/files/{id}';

  // Bulk Operations
  static const String bulkUploadStudents = '/bulk/students/upload';
  static const String bulkUploadTeachers = '/bulk/teachers/upload';
  static const String bulkMarkAttendance = '/bulk/attendance/mark';

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String contentTypeUrlEncoded = 'application/x-www-form-urlencoded';

  // Query Parameters
  static const String paramPage = 'page';
  static const String paramLimit = 'limit';
  static const String paramSearch = 'search';
  static const String paramSort = 'sort';
  static const String paramOrder = 'order';
  static const String paramDate = 'date';
  static const String paramStartDate = 'start_date';
  static const String paramEndDate = 'end_date';
  static const String paramSchoolId = 'school_id';
  static const String paramClassId = 'class_id';
  static const String paramStudentId = 'student_id';
  static const String paramTeacherId = 'teacher_id';

  // Response Codes
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int noContentCode = 204;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int conflictCode = 409;
  static const int serverErrorCode = 500;

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
