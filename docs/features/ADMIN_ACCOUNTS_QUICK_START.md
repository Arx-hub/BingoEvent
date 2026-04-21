# Admin Account Management - Quick Start Guide

## 🚀 Getting Started (5 Minutes)

### 1. **First Time Setup**
After deploying the updated backend, the master admin account is automatically created:
- **Username**: `admin`
- **Password**: `admin123`

⚠️ **IMPORTANT**: Change this password immediately in production!

### 2. **Login to Admin App**
1. Open your browser to `http://localhost:8082`
2. You'll see the login screen
3. Enter credentials:
   - Username: `admin`
   - Password: `admin123`
4. Click "Login"

### 3. **What You See as Master**
- 7 tabs in the dashboard
- New tab: **Admin Accounts** (last tab)
- Your username appears in the AppBar with "(Master)" label
- Logout button in the top-right

---

## 👥 Creating New Administrators

### Steps:
1. Login as master (`admin/admin123`)
2. Click the **Admin Accounts** tab
3. Click **"Create New Admin"** button
4. Fill in the form:
   - **Username**: At least 3 characters
   - **Password**: At least 6 characters
5. Click **"Create"**
6. Success! New admin appears in the list

### Share credentials with new admin
Give them the username and password to log in. They'll see only 6 tabs (no Admin Accounts).

---

## 🔐 Security & Access Control

### Master Account Features
- ✅ View all admin accounts
- ✅ Create new admin accounts  
- ✅ Edit other admins' username/password
- ✅ Delete other admin accounts
- ✅ Access ALL 7 tabs including Admin Accounts tab
- ✅ Protected from deletion/modification

### Regular Admin Accounts
- ✅ Full access to Events, Welcome Pages, Bingo Boards, etc.
- ❌ Cannot see "Admin Accounts" tab
- ❌ Cannot create/edit/delete accounts
- ❌ Cannot access admin management functions

---

## ✏️ Managing Existing Accounts

### View All Accounts
1. Go to **Admin Accounts** tab
2. See list of all admins with:
   - Username
   - "Master Account" badge (if applicable)
   - Creation date
   - Edit/Delete icons (non-master only)

### Edit an Account
1. Click the **Edit** (pencil) icon next to the account
2. Update username and/or password
3. Leave password empty to keep current password
4. Click **"Update"**

### Delete an Account
1. Click the **Delete** (trash) icon next to the account
2. Confirm deletion in the dialog
3. Account is removed immediately

**Note**: Master account has no edit/delete buttons - it's protected!

---

## 🚪 Login & Logout

### Login
1. On login screen, enter username and password
2. Click "Login"
3. You're logged in and see the dashboard

### Change your Password
1. Go to **Admin Accounts** tab
2. Find your account name
3. Click **Edit** (if you're not master, you can't edit)
4. Update password

*Tip: Ask another master to edit your password if needed*

### Logout
1. Click **"Logout"** button (top-right of AppBar)
2. Confirm logout
3. Back to login screen

---

## 🔍 Troubleshooting

### I can't see the Admin Accounts tab
**Solution**: You're not logged in as master. Only the master account (`admin`) can see this tab.

### I forgot my password
**Solution**: Ask another master to edit your account in the Admin Accounts tab and set a new password.

### I forgot the master password
**Solution**: 
- Stop the API server
- Delete the database file: `./database/BingoEvent.db`
- Restart the server
- It will recreate the database with default credentials: `admin/admin123`

### Login failed
**Solution**:
- Check your username spelling (case-sensitive)
- Verify your password is from latest reset
- Contact your master administrator

---

## 📊 Account List Information

For each admin, you can see:
- **Username**: Login name
- **Master Account**: Badge shown for master only
- **Created**: Account creation date/time
- **Edit/Delete**: Buttons for non-master accounts only

---

## 💡 Best Practices

1. **Change default password** - Change `admin/admin123` to a strong password immediately
2. **Use strong passwords** - At least 12 characters with mixed case and numbers
3. **Regular password updates** - Change passwords every 90 days
4. **Limited admins** - Only create admin accounts for people who need them
5. **Watch the log** - Monitor who creates/deletes accounts
6. **Backup master credentials** - Keep master password in secure location

---

## 📝 Account Requirements

- **Username**: 
  - Minimum 3 characters
  - Must be unique (no duplicates)
  - Case-sensitive

- **Password**:
  - Minimum 6 characters
  - No complexity requirements (consider adding in production!)
  - Case-sensitive

---

## 🆘 Need Help?

If you encounter issues:
1. Check the browser console (F12) for error messages
2. Check API logs at `http://localhost:5000/health`
3. Verify the API is running (`docker compose ps`)
4. Check your internet connection
5. Contact your system administrator

---

## 🔄 Resetting the System

To reset all admin accounts to defaults:

```bash
# Stop everything
docker compose down

# Delete the database
rm database/BingoEvent.db

# Restart
docker compose up -d

# Login with default credentials
# Username: admin
# Password: admin123
```

This will recreate the database with only the master account.
