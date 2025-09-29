**Overall App Vision:** A Software as a Service (SaaS) mobile application for schools to manage student attendance and fee collection, with an offline-first and online-later approach. It needs to be fast, intuitive, and support various screen sizes and operating systems (iOS and Android, including older versions). The app will initially be free, with a plan for paid services later.

**Core Functionality:**

*   **Offline-First Capability:** The app should function seamlessly even without an internet connection, storing data locally on the device (using SQLite as discussed) and syncing automatically when connectivity is restored. Users should also have the option to manually trigger a sync.
*   **User Authentication:** Secure and convenient login options are essential. The app will support:
    *   Phone number with OTP (One-Time Password) for easy access, without requiring SMS for OTP delivery to minimize costs and ensure reliability.
*   **User Roles:** The app will have at least two main user roles:
    *   **Staff (Teachers):** Primarily focused on daily operations like attendance and fee collection.
    *   **Admin (Headmaster/Director):** Responsible for overall school setup, student management, and comprehensive reporting.
*   **Theme Options:** The app should offer both dark and light mode themes for user preference.

**Staff User Perspective:**

*   **Student Identification:** Staff should be able to quickly identify students for attendance and fee collection. This will be done by searching for student names or using student IDs.
*   **Fee Collection:**
    *   **Canteen Fees:** Collect a fixed amount (e.g., 9 cities) per day.
    *   **Transportation Fees:** Collect varying amounts based on location, with the flexibility to record partial payments for specific dates.
    *   **Payment Recording:** Easily record payments received from parents, specifying the dates the payment covers (e.g., daily, 3 days, weekly).
    *   **Payment Status:** Quickly see who hasn't paid for the day or week.
*   **Reporting (Staff Level):**
    *   Access basic reports on daily collections.
    *   View the total amounts collected for the day.
    *   See informational details relevant to their duties.
*   **Student Management (Staff Level):**
    *   Add new students who join later, quickly specifying their class.
*   **Calendar View:** A simple calendar displaying holidays and payment deadlines.

**Admin User Perspective:**

*   **School Setup:** Upon registration, the admin should be able to set up school details.
*   **Student Management:**
    *   **Bulk Upload:** Easily bulk upload student data (name, class, basic details).
    *   **Student Information:** Access and manage all student information.
*   **Comprehensive Reporting:** Generate various types of reports based on collected data, including:
    *   Attendance reports.
    *   Detailed fee collection reports.
    *   Financial summaries.
*   **Holiday Management:** Mark specific days as holidays on the calendar.
*   **Waivers and Scholarships:** Mark students as having waivers or scholarships.

**Technical Considerations (as discussed):**

*   **Backend:** Supabase (self-hostable for future data control).
*   **Local Database:** SQLite for offline data storage and synchronization.
*   **Frontend:** Cross-platform framework like Flutter or React Native for broad device compatibility.
