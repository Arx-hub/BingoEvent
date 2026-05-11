# API Reference

This folder contains API documentation and testing guides.

## Files in This Folder

### 🔐 [ADMIN_ACCOUNTS_API.md](./ADMIN_ACCOUNTS_API.md)
**Admin accounts authentication API**
- Login endpoints
- Registration endpoints
- Token management
- Permission levels
- Security considerations

**Best for**: Understanding admin authentication

---

### 📖 [TECHNICAL_REFERENCE.md](./TECHNICAL_REFERENCE.md)
**Complete API technical reference**
- All endpoints documented
- Request/response formats
- Error codes and handling
- Data models
- Examples for each endpoint
- Rate limiting (if applicable)

**Best for**: API implementation and integration

---

### 🧪 [POSTMAN_GUIDE.md](./POSTMAN_GUIDE.md)
**Testing APIs with Postman**
- Postman installation
- Collection setup
- Environment configuration
- Running requests
- Batch testing
- Exporting results

**Best for**: Testing and validating API endpoints

---

## API Endpoints Overview

**Bingo Management:**
- `/api/bingo/boards` - Board operations
- `/api/bingo/events` - Event management
- `/api/bingo/published-event` - Get current event

**Admin Accounts:**
- `/api/auth/login` - Admin login
- `/api/auth/register` - Create admin account

**Game Management:**
- `/api/bingo/question-packages` - Question data
- `/api/bingo/minigames` - Game operations

**Feedback:**
- `/api/bingo/feedback` - User feedback

For complete details, see [TECHNICAL_REFERENCE.md](./TECHNICAL_REFERENCE.md)

---

## API Testing Workflow

1. **Read Documentation**
   - Start with [TECHNICAL_REFERENCE.md](./TECHNICAL_REFERENCE.md)

2. **Setup Postman**
   - Follow [POSTMAN_GUIDE.md](./POSTMAN_GUIDE.md)

3. **Test Endpoints**
   - Use provided collection
   - Verify responses

4. **Admin Authentication**
   - Refer to [ADMIN_ACCOUNTS_API.md](./ADMIN_ACCOUNTS_API.md)

5. **Debug Issues**
   - See [`../troubleshooting/`](../troubleshooting/)

---

## Quick Links

**Authentication:**
- [Admin Login](./ADMIN_ACCOUNTS_API.md)
- [Token Management](./TECHNICAL_REFERENCE.md)

**Game Operations:**
- [Bingo Boards](./TECHNICAL_REFERENCE.md)
- [Events](./TECHNICAL_REFERENCE.md)
- [Games](./TECHNICAL_REFERENCE.md)

**Testing:**
- [Postman Setup](./POSTMAN_GUIDE.md)

---

## Common API Patterns

All endpoints follow REST conventions:
- `GET` - Retrieve data
- `POST` - Create/Submit data
- `PUT` - Update data
- `DELETE` - Remove data

See [TECHNICAL_REFERENCE.md](./TECHNICAL_REFERENCE.md) for details on each endpoint.

---

## Next Steps

- Testing APIs? → See [POSTMAN_GUIDE.md](./POSTMAN_GUIDE.md)
- Implementing features? → See [`../features/`](../features/)
- Database questions? → See [`../database/`](../database/)

---

**See also**: [Back to Documentation Index](../README.md)
