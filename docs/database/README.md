# Database

This folder contains database documentation.

## Files in This Folder

### 🗄️ [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md)
**Complete Bingo board database documentation**
- Database schema
- Table structures
- Data relationships
- Key definitions
- Data types
- Constraints
- Example data
- Query examples

**Best for**: Understanding the database structure, writing queries, data modeling

---

## Database Overview

The Bingo Event system uses **SQLite** for data storage.

### Main Tables:
- **Users** - Admin users and guests
- **BingoBoards** - Bingo board definitions
- **Events** - Event configurations
- **Questions** - Question packages
- **Feedback** - User feedback

For complete schema details, see [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md)

---

## Common Tasks

**I need to...**

- **Understand the data model**
  → Read [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md)

- **Query the database**
  → See schema in [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md)

- **Add new data**
  → Check table structures in [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md)

- **Modify the schema**
  → Understand relationships in [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md)

---

## Database Files

- **Location**: `API_folder/Data/BingoEvent.db`
- **Type**: SQLite 3
- **Permissions**: Read/Write (API service)
- **Backup**: Recommended before major changes

---

## Quick Schema Reference

See [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md) for:
- All table names
- Column names and types
- Primary keys
- Foreign keys
- Indexes
- Constraints

---

## Next Steps

- Deploying? → See [`../deployment/`](../deployment/)
- Need to query data? → See database schema in [BINGO_BOARD_DATABASE.md](./BINGO_BOARD_DATABASE.md)
- Working with features? → See [`../features/`](../features/)

---

**See also**: [Back to Documentation Index](../README.md)
