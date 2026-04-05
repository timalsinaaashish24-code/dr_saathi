# Patient Registration Troubleshooting Guide

## 🔍 Common Issues & Solutions

### Issue 1: Cannot Register New Patient
**Symptoms:** Registration form submits but fails, shows "Registration failed" error

**Potential Causes & Solutions:**

1. **Database Connection Issues**
   - **Solution:** Use the "Debug Patient Registration" button on the main screen
   - **Check:** Look for database connection errors in the debug logs
   - **Fix:** Try the "Fix Database" button first

2. **Email Already Exists**
   - **Solution:** Try a different email address
   - **Check:** The debug tool will show if email already exists
   - **Note:** This includes the demo patient email `patient@example.com`

3. **Required Field Validation**
   - **Solution:** Ensure all required fields are filled:
     - ✅ Full Name (required)
     - ✅ Email (required, valid format)
     - ✅ Password (required, min 6 characters for new accounts)
   - Optional fields can be left empty

4. **Database Table Missing**
   - **Solution:** Run "Fix Database" from main screen
   - **Technical:** The patient auth table might not be created

### Issue 2: Demo Login Not Working
**Symptoms:** Demo login button doesn't work or shows errors

**Solutions:**
1. **First Time Setup:**
   - Click "Demo Login" button - it will create the demo patient automatically
   - Default credentials: `patient@example.com` / `password123`

2. **Database Issues:**
   - Use "Fix Database" button first
   - Then try "Demo Login" again

### Issue 3: App Crashes During Registration
**Symptoms:** App closes or freezes during registration

**Solutions:**
1. **Check Device Storage:** Ensure sufficient storage space
2. **Restart App:** Close and reopen the application
3. **Database Repair:** Use "Fix Database" button
4. **Clear App Data:** (Android) Clear app data in device settings

## 🛠 Debug Tools Available

### Debug Patient Registration Tool
Access via main screen "Debug Patient Registration" button:

1. **Test Database Connection**: Verifies database setup
2. **Test Registration Flow**: Creates a test patient with unique email
3. **Test Demo Patient**: Verifies demo patient creation and login

### Debug Information
The debug tool provides detailed logs showing:
- ✅ Success indicators
- ❌ Error indicators  
- Database connection status
- Registration step-by-step progress
- Login verification results

## 📱 Step-by-Step Testing Process

### For New Users:
1. Launch the Dr. Saathi app
2. Click "Patient Portal" on main screen
3. Click "Don't have an account? Sign Up"
4. Fill required information:
   - Full Name: `Your Name`
   - Email: `your.email@example.com` (use unique email)
   - Password: `yourpassword` (minimum 6 characters)
5. Optional: Fill phone, gender, address
6. Click "Create Account"

### For Testing:
1. Use "Debug Patient Registration" button
2. Run all three tests in order:
   - Database Connection Test
   - Registration Flow Test  
   - Demo Patient Test
3. Check logs for any ❌ errors

## 🔧 Technical Details

### Database Information:
- **Table Name:** `patients_auth`
- **Database File:** `patients_auth.db`
- **Location:** App's private storage
- **Fields:** email, password_hash, full_name, phone_number, etc.

### Authentication Flow:
1. Form validation
2. Database connection
3. Check existing email
4. Password hashing (SHA-256)
5. Insert new record
6. Auto-login after registration
7. Navigate to patient dashboard

## ❓ Still Having Issues?

### Contact Information:
If problems persist after trying these solutions:

1. **Use Debug Tool:** Capture the error logs from debug tool
2. **Note Error Messages:** Write down exact error messages
3. **Check Console:** Development console may show additional errors
4. **Device Info:** Note your device type and OS version

### Quick Test:
Try the demo patient first:
- Click "Demo Login" button
- Should automatically log you in and show patient dashboard
- From dashboard, click "My Invoices" to see sample data

---

## ✅ Successful Registration Indicators:
- No error messages displayed
- Automatic redirect to patient dashboard  
- Patient name shows in dashboard welcome card
- "My Invoices" accessible from dashboard
- Sample invoices visible (if using demo account)