using Microsoft.Data.Sqlite;
using System;
using System.Collections.Generic;

namespace BingoEvent.API.Data
{
    public class BingoBoardCell
    {
        public int Id { get; set; }
        public int BingoBoardId { get; set; }
        public int Row { get; set; }
        public int Column { get; set; }
        public string Text { get; set; }
        public bool IsMarked { get; set; }
    }

    public class BingoBoardInfo
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class BingoBoardDb
    {
        private readonly string _connectionString;

        public BingoBoardDb(string connectionString)
        {
            _connectionString = connectionString;
            InitializeDatabase();
        }

        /// <summary>
        /// Initializes the database with required tables
        /// </summary>
        public void InitializeDatabase()
        {
            using (var connection = new SqliteConnection(_connectionString))
            {
                connection.Open();

                // Create BingoBoards table
                using (var createBingoBoardsCmd = connection.CreateCommand())
                {
                    createBingoBoardsCmd.CommandText = @"
                        CREATE TABLE IF NOT EXISTS BingoBoards (
                            Id INTEGER PRIMARY KEY AUTOINCREMENT,
                            Name TEXT NOT NULL,
                            CreatedAt TEXT NOT NULL
                        );";
                    createBingoBoardsCmd.ExecuteNonQuery();
                }

                // Create BingoBoardCells table
                using (var createCellsCmd = connection.CreateCommand())
                {
                    createCellsCmd.CommandText = @"
                        CREATE TABLE IF NOT EXISTS BingoBoardCells (
                            Id INTEGER PRIMARY KEY AUTOINCREMENT,
                            BingoBoardId INTEGER NOT NULL,
                            Row INTEGER NOT NULL,
                            Column INTEGER NOT NULL,
                            Text TEXT NOT NULL,
                            IsMarked INTEGER NOT NULL DEFAULT 0,
                            FOREIGN KEY(BingoBoardId) REFERENCES BingoBoards(Id) ON DELETE CASCADE
                        );";
                    createCellsCmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Creates a new bingo board with 5x5 cells
        /// </summary>
        public int CreateBingoBoard(string name, string[,] boardContent)
        {
            if (boardContent.GetLength(0) != 5 || boardContent.GetLength(1) != 5)
            {
                throw new ArgumentException("Bingo board must be 5x5");
            }

            using (var connection = new SqliteConnection(_connectionString))
            {
                connection.Open();

                // Insert new bingo board
                int boardId;
                using (var insertBoardCmd = connection.CreateCommand())
                {
                    insertBoardCmd.CommandText = @"
                        INSERT INTO BingoBoards (Name, CreatedAt)
                        VALUES ($Name, $CreatedAt);
                        SELECT last_insert_rowid();";
                    insertBoardCmd.Parameters.AddWithValue("$Name", name);
                    insertBoardCmd.Parameters.AddWithValue("$CreatedAt", DateTime.UtcNow.ToString("o"));
                    boardId = Convert.ToInt32(insertBoardCmd.ExecuteScalar());
                }

                // Insert all cells
                for (int row = 0; row < 5; row++)
                {
                    for (int col = 0; col < 5; col++)
                    {
                        using (var insertCellCmd = connection.CreateCommand())
                        {
                            insertCellCmd.CommandText = @"
                                INSERT INTO BingoBoardCells (BingoBoardId, Row, Column, Text, IsMarked)
                                VALUES ($BingoBoardId, $Row, $Column, $Text, 0);";
                            insertCellCmd.Parameters.AddWithValue("$BingoBoardId", boardId);
                            insertCellCmd.Parameters.AddWithValue("$Row", row);
                            insertCellCmd.Parameters.AddWithValue("$Column", col);
                            insertCellCmd.Parameters.AddWithValue("$Text", boardContent[row, col]);
                            insertCellCmd.ExecuteNonQuery();
                        }
                    }
                }

                return boardId;
            }
        }

        /// <summary>
        /// Retrieves all bingo boards
        /// </summary>
        public List<BingoBoardInfo> GetAllBingoBoards()
        {
            var boards = new List<BingoBoardInfo>();

            using (var connection = new SqliteConnection(_connectionString))
            {
                connection.Open();

                using (var cmd = connection.CreateCommand())
                {
                    cmd.CommandText = "SELECT Id, Name, CreatedAt FROM BingoBoards ORDER BY CreatedAt DESC";

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            boards.Add(new BingoBoardInfo
                            {
                                Id = reader.GetInt32(0),
                                Name = reader.GetString(1),
                                CreatedAt = DateTime.Parse(reader.GetString(2))
                            });
                        }
                    }
                }
            }

            return boards;
        }

        /// <summary>
        /// Retrieves a specific bingo board with all its cells
        /// </summary>
        public (BingoBoardInfo board, List<BingoBoardCell> cells) GetBingoBoardById(int boardId)
        {
            BingoBoardInfo board = null;
            var cells = new List<BingoBoardCell>();

            using (var connection = new SqliteConnection(_connectionString))
            {
                connection.Open();

                // Get board info
                using (var boardCmd = connection.CreateCommand())
                {
                    boardCmd.CommandText = "SELECT Id, Name, CreatedAt FROM BingoBoards WHERE Id = $Id";
                    boardCmd.Parameters.AddWithValue("$Id", boardId);

                    using (var reader = boardCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            board = new BingoBoardInfo
                            {
                                Id = reader.GetInt32(0),
                                Name = reader.GetString(1),
                                CreatedAt = DateTime.Parse(reader.GetString(2))
                            };
                        }
                    }
                }

                // Get cells
                using (var cellsCmd = connection.CreateCommand())
                {
                    cellsCmd.CommandText = @"
                        SELECT Id, BingoBoardId, Row, Column, Text, IsMarked
                        FROM BingoBoardCells
                        WHERE BingoBoardId = $BingoBoardId
                        ORDER BY Row, Column";
                    cellsCmd.Parameters.AddWithValue("$BingoBoardId", boardId);

                    using (var reader = cellsCmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            cells.Add(new BingoBoardCell
                            {
                                Id = reader.GetInt32(0),
                                BingoBoardId = reader.GetInt32(1),
                                Row = reader.GetInt32(2),
                                Column = reader.GetInt32(3),
                                Text = reader.GetString(4),
                                IsMarked = reader.GetInt32(5) == 1
                            });
                        }
                    }
                }
            }

            return (board, cells);
        }

        /// <summary>
        /// Updates the text in a specific cell
        /// </summary>
        public void UpdateCellText(int cellId, string newText)
        {
            using (var connection = new SqliteConnection(_connectionString))
            {
                connection.Open();

                using (var cmd = connection.CreateCommand())
                {
                    cmd.CommandText = "UPDATE BingoBoardCells SET Text = $Text WHERE Id = $Id";
                    cmd.Parameters.AddWithValue("$Text", newText);
                    cmd.Parameters.AddWithValue("$Id", cellId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Marks or unmarks a cell
        /// </summary>
        public void MarkCell(int cellId, bool isMarked)
        {
            using (var connection = new SqliteConnection(_connectionString))
            {
                connection.Open();

                using (var cmd = connection.CreateCommand())
                {
                    cmd.CommandText = "UPDATE BingoBoardCells SET IsMarked = $IsMarked WHERE Id = $Id";
                    cmd.Parameters.AddWithValue("$IsMarked", isMarked ? 1 : 0);
                    cmd.Parameters.AddWithValue("$Id", cellId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Deletes a bingo board and all its cells
        /// </summary>
        public void DeleteBingoBoard(int boardId)
        {
            using (var connection = new SqliteConnection(_connectionString))
            {
                connection.Open();

                using (var cmd = connection.CreateCommand())
                {
                    cmd.CommandText = "DELETE FROM BingoBoards WHERE Id = $Id";
                    cmd.Parameters.AddWithValue("$Id", boardId);
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
