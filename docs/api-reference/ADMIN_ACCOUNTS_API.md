# Admin Account Management - API Documentation

## 📚 Complete API Reference

### Base URL
```
http://localhost:5000/api/auth
```

---

## 🔑 Authentication Endpoints

### `POST /login`
Authenticate an admin user with username and password.

**Request:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "adminId": 1,
  "username": "admin",
  "isMaster": true,
  "token": "MXxhZG1pbnx0cnVlfDE3MzkyMjM0NTY="
}
```

**Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Invalid username or password"
}
```

**Status Codes:**
- `200` - Login successful
- `401` - Invalid credentials
- `400` - Missing username or password

**CURL Example:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

---

### `POST /verify`
Verify current admin session.

**Query Parameters:**
- `adminId` (int, required) - The admin ID to verify

**Request:**
```
POST /api/auth/verify?adminId=1
```

**Response (200 OK):**
```json
{
  "success": true,
  "adminId": 1,
  "username": "admin",
  "isMaster": true
}
```

**Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Session invalid"
}
```

---

## 👥 Admin Management Endpoints

### `GET /admin/all`
Get list of all admin accounts. **Master only**.

**Query Parameters:**
- `adminId` (int, required) - Master admin ID

**Request:**
```
GET /api/auth/admin/all?adminId=1
```

**Response (200 OK):**
```json
{
  "success": true,
  "admins": [
    {
      "id": 1,
      "username": "admin",
      "isMaster": true,
      "createdAt": "2026-01-01T00:00:00"
    },
    {
      "id": 2,
      "username": "john_doe",
      "isMaster": false,
      "createdAt": "2026-03-15T10:30:45"
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `403` - Not master account (Forbidden)

---

### `POST /admin/create`
Create a new admin account. **Master only**.

**Query Parameters:**
- `adminId` (int, required) - Master admin ID

**Request:**
```json
{
  "username": "newadmin",
  "password": "secure123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Admin account created successfully",
  "adminId": 3,
  "username": "newadmin"
}
```

**Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Username must be at least 3 characters"
}
```

Possible error messages:
- "Username and password are required"
- "Username must be at least 3 characters"
- "Password must be at least 6 characters"
- "Username already exists"

**Status Codes:**
- `200` - Account created
- `400` - Validation error (see message)
- `403` - Not master account

**CURL Example:**
```bash
curl -X POST http://localhost:5000/api/auth/admin/create?adminId=1 \
  -H "Content-Type: application/json" \
  -d '{"username":"newadmin","password":"secure123"}'
```

---

### `PUT /admin/update`
Update an admin account. **Master only** (can update any non-master account).

**Query Parameters:**
- `adminId` (int, required) - Master admin ID performing the update

**Request:**
```json
{
  "id": 2,
  "username": "jane_doe",
  "password": "newpassword123"
}
```

**Notes:**
- `password` is optional - leave empty/null to keep current
- `username` is optional - only update if different from current
- `id` is required - ID of account to update

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Admin account updated successfully",
  "adminId": 2,
  "username": "jane_doe"
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "Account not found"
}
```

**Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Cannot modify the master account"
}
```

Possible error messages:
- "Account not found"
- "Cannot modify the master account"
- "Username must be at least 3 characters"
- "Username already exists"
- "Password must be at least 6 characters"

**Status Codes:**
- `200` - Account updated
- `400` - Validation error or cannot modify master
- `403` - Not master account
- `404` - Account not found

**CURL Example:**
```bash
curl -X PUT http://localhost:5000/api/auth/admin/update?adminId=1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": 2,
    "username": "jane_doe",
    "password": "newpassword123"
  }'
```

---

### `DELETE /admin/delete/{id}`
Delete an admin account. **Master only** (cannot delete master).

**Path Parameters:**
- `id` (int, required) - Admin ID to delete

**Query Parameters:**
- `adminId` (int, required) - Master admin ID performing deletion

**Request:**
```
DELETE /api/auth/admin/delete/2?adminId=1
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Admin account deleted successfully"
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "Account not found"
}
```

**Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Cannot delete the master account"
}
```

**Status Codes:**
- `200` - Account deleted
- `400` - Cannot delete master account
- `403` - Not master account  
- `404` - Account not found

**CURL Example:**
```bash
curl -X DELETE http://localhost:5000/api/auth/admin/delete/2?adminId=1
```

---

## 🔒 Access Control

### Master Account
Master account ID: Must have `isMaster = true` in database.

Can:
- ✅ Access all endpoints marked "Master only"
- ✅ Create new accounts
- ✅ Edit any non-master account
- ✅ Delete any non-master account
- ✅ Cannot modify or delete themselves (protected)

Cannot:
- ❌ Be modified or deleted
- ❌ Have `isMaster` flag changed

### Regular Admin Account
Regular accounts have `isMaster = false`.

Can:
- ✅ Login
- ✅ Use `/verify` to check their session
- ✅ Access `adminId` only (none of the `/admin/*` endpoints)

Cannot:
- ❌ Access any `/admin/*` endpoints
- ❌ Get 403 Forbidden if they try

---

## 🗝️ Default Master Account

**Username**: `admin`  
**Password**: `admin123`

This account is automatically created on first database initialization.

---

## 📊 Sample Workflow

### 1. Master logs in
```bash
POST /login
{
  "username": "admin",
  "password": "admin123"
}
# Response: adminId = 1, isMaster = true
```

### 2. Master creates new account
```bash
POST /admin/create?adminId=1
{
  "username": "alice",
  "password": "password123"
}
# Response: New account created with adminId = 2
```

### 3. Alice logs in
```bash
POST /login
{
  "username": "alice",
  "password": "password123"
}
# Response: adminId = 2, isMaster = false
```

### 4. Master lists all accounts
```bash
GET /admin/all?adminId=1
# Response: List of all admin accounts
```

### 5. Master updates Alice's password
```bash
PUT /admin/update?adminId=1
{
  "id": 2,
  "password": "newpassword456"
}
# Alice can now login with new password
```

### 6. Master deletes Alice's account
```bash
DELETE /admin/delete/2?adminId=1
# Alice account is deleted, cannot login anymore
```

---

## ⚠️ Error Handling

All endpoints return JSON responses. Errors include:
- `success`: false
- `message`: Human-readable error description

### Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request succeeded |
| 400 | Bad Request - Validation or logic error |
| 401 | Unauthorized - Invalid credentials |
| 403 | Forbidden - Not authorized (e.g., non-master) |
| 404 | Not Found - Resource doesn't exist |
| 500 | Server Error - Unexpected error |

---

## 🔐 Security Notes

### Current Implementation
- Base64 password hashing (NOT secure for production)
- Simple token format (NOT secure for production)
- No rate limiting
- No account lockout
- No session timeout

### Production Recommendations
1. Use bcrypt or Argon2 for password hashing
2. Implement JWT tokens with expiration
3. Add rate limiting (e.g., 5 login attempts per 15 minutes)
4. Add account lockout after N failed attempts
5. Implement session timeout (30 min - 24 hours)
6. Use HTTPS only
7. Add CORS restrictions
8. Implement audit logging for all admin actions
9. Add refresh token rotation
10. Implement IP whitelisting if possible

---

## 📝 Integration Examples

### JavaScript/Fetch
```javascript
const login = async (username, password) => {
  const response = await fetch('http://localhost:5000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  });
  return response.json();
};

const result = await login('admin', 'admin123');
console.log(result); // { success: true, adminId: 1, ... }
```

### Python/Requests
```python
import requests

response = requests.post(
  'http://localhost:5000/api/auth/login',
  json={'username': 'admin', 'password': 'admin123'}
)
result = response.json()
print(result)  # {'success': True, 'adminId': 1, ...}
```

### cURL
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

---

## 🐛 Testing Checklist

- [ ] Login with valid credentials works
- [ ] Login with invalid credentials fails
- [ ] Master can create accounts
- [ ] Non-master cannot create accounts  
- [ ] Master can list all accounts
- [ ] Non-master cannot list accounts
- [ ] Master can update non-master account
- [ ] Master cannot update master account
- [ ] Master can delete non-master account
- [ ] Master cannot delete master account
- [ ] Non-master cannot delete accounts
- [ ] New account can login immediately
- [ ] Updated password works after change
- [ ] Deleted account cannot login
- [ ] All error messages are clear
