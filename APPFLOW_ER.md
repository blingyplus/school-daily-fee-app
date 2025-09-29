Perfect! I've created a comprehensive application flow diagram that covers the complete user journey for both Admins and Teachers. Here's a summary of the key flows:

## **Key Application Flows:**

### **1. Admin Journey:**

**Initial Onboarding (First-time Admin):**
- School setup → Classes → Fee structure → Holiday calendar
- Import teachers (bulk upload or manual)
- Import students (bulk upload or manual)
- Configure individual student fees & scholarships

**Returning Admin Features:**
- **Reports Hub**: Attendance, Fee Collections, Financial Summary, Defaulters
  - All reports can be exported as Excel, PDF, or Word
- **Management Modules**: Students, Teachers, Classes
- **Daily Operations**: Can also mark attendance and collect fees
- **Calendar Management**: Mark holidays and important dates
- **School Settings**: Configure fees, themes, sync settings, backup data

### **2. Teacher Journey:**

**Multi-School Support:**
- Select active school if associated with multiple schools
- Switch between schools anytime

**Core Operations:**
- **Mark Attendance**: 
  - Select class → Mark individual or bulk (all present/absent)
  - Saves locally → Syncs when online
  
- **Collect Fees**:
  - Search student → Select fee type (Canteen/Transport)
  - Choose date coverage (single/multiple days/week)
  - Apply scholarships/waivers automatically
  - Record payment method → Generate receipt
  - Option to print/share receipt

- **Reports**: 
  - Daily collections, personal collection history, class attendance, defaulters
  - Export as Excel, PDF, or Word

- **Quick Add Student**: For late enrollments

### **3. Offline-First Architecture:**
- All operations save to local SQLite first
- Background sync service constantly checks for connectivity
- Queues unsynchronized data for automatic sync
- Warning on logout if unsynced data exists

### **4. Report Export Options:**
Every report can be exported in three formats:
- **.xlsx (Excel)** - For data analysis and further processing
- **.pdf** - For official documentation and printing
- **.docx (Word)** - For editing and customization

The flow ensures smooth operation regardless of internet connectivity, with clear visual feedback on sync status and comprehensive functionality for both administrative and daily operational tasks.

Would you like me to create additional flows for specific scenarios, such as conflict resolution during sync or detailed onboarding screens?