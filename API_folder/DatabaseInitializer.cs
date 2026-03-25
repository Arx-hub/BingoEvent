using Microsoft.Data.Sqlite;
using System;

namespace BingoEvent.API;

public static class DatabaseInitializer
{
    /// <summary>
    /// Creates all database tables if they don't already exist using raw SQLite commands.
    /// This avoids EF Core migration conflicts with existing databases.
    /// </summary>
    public static void Initialize(string connectionString)
    {
        using var connection = new SqliteConnection(connectionString);
        connection.Open();

        // BingoBoards table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS BingoBoards (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT NOT NULL DEFAULT '',
                    Boxes TEXT NOT NULL DEFAULT '[]',
                    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
                    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
                    IsActive INTEGER NOT NULL DEFAULT 1
                );";
            cmd.ExecuteNonQuery();
        }

        // HelloWorldEntries table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS HelloWorldEntries (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Message TEXT,
                    CreatedAt TEXT NOT NULL DEFAULT (datetime('now'))
                );";
            cmd.ExecuteNonQuery();
        }

        // WelcomePages table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS WelcomePages (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT,
                    Title TEXT NOT NULL DEFAULT '',
                    Subtitle TEXT NOT NULL DEFAULT ''
                );";
            cmd.ExecuteNonQuery();
        }

        // Games table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS Games (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT
                );";
            cmd.ExecuteNonQuery();
        }

        // Events table
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = @"
                CREATE TABLE IF NOT EXISTS Events (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    Name TEXT NOT NULL DEFAULT '',
                    Creator TEXT NOT NULL DEFAULT '',
                    WelcomePageId INTEGER NOT NULL,
                    BingoBoardId INTEGER NOT NULL,
                    GameNames TEXT NOT NULL DEFAULT '[]',
                    FOREIGN KEY(WelcomePageId) REFERENCES WelcomePages(Id),
                    FOREIGN KEY(BingoBoardId) REFERENCES BingoBoards(Id)
                );";
            cmd.ExecuteNonQuery();
        }

        // Add missing columns to Events if they don't exist (for existing DBs)
        AddColumnIfNotExists(connection, "Events", "GameNames", "TEXT NOT NULL DEFAULT '[]'");

        // Add missing columns to BingoBoards if they don't exist (for existing DBs)
        // Note: ALTER TABLE ADD COLUMN only allows constant defaults in SQLite
        AddColumnIfNotExists(connection, "BingoBoards", "Boxes", "TEXT NOT NULL DEFAULT '[]'");
        AddColumnIfNotExists(connection, "BingoBoards", "CreatedAt", "TEXT NOT NULL DEFAULT '2026-01-01 00:00:00'");
        AddColumnIfNotExists(connection, "BingoBoards", "UpdatedAt", "TEXT NOT NULL DEFAULT '2026-01-01 00:00:00'");
        AddColumnIfNotExists(connection, "BingoBoards", "IsActive", "INTEGER NOT NULL DEFAULT 1");

        // Add missing columns to WelcomePages if they don't exist (for existing DBs)
        AddColumnIfNotExists(connection, "WelcomePages", "Title", "TEXT NOT NULL DEFAULT ''");
        AddColumnIfNotExists(connection, "WelcomePages", "Subtitle", "TEXT NOT NULL DEFAULT ''");

        // Seed default WelcomePage if empty
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = "INSERT OR IGNORE INTO WelcomePages (Id, Name, Title, Subtitle) VALUES (1, 'Default Welcome Page', 'Welcome!', '');";
            cmd.ExecuteNonQuery();
        }

        // Seed default Game if empty
        using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = "INSERT OR IGNORE INTO Games (Id, Name) VALUES (1, 'Default Game');";
            cmd.ExecuteNonQuery();
        }

        Console.WriteLine("Database initialized successfully.");
    }

    private static void AddColumnIfNotExists(SqliteConnection connection, string table, string column, string definition)
    {
        using var cmd = connection.CreateCommand();
        cmd.CommandText = $"PRAGMA table_info({table});";
        using var reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            if (reader.GetString(1) == column)
                return;
        }
        reader.Close();

        using var alterCmd = connection.CreateCommand();
        alterCmd.CommandText = $"ALTER TABLE {table} ADD COLUMN {column} {definition};";
        alterCmd.ExecuteNonQuery();
    }
}
