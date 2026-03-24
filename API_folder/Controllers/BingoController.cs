using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using BingoEvent.API.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BingoEvent.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [EnableCors("AllowAll")]
    public class BingoController : ControllerBase
    {
        private readonly BingoBoardDb _bingoBoardDb;

        public BingoController(BingoBoardDb bingoBoardDb)
        {
            _bingoBoardDb = bingoBoardDb;
        }

        /// <summary>
        /// Health check endpoint
        /// </summary>
        [HttpGet("/health")]
        public IActionResult Health()
        {
            return Ok(new { Status = "Healthy", Timestamp = DateTime.UtcNow });
        }
        [HttpPost("issue-board")]
        public IActionResult IssueBoard([FromBody] IssueBoardRequest request)
        {
            try
            {
                // Generate a 5x5 bingo board with provided text or placeholder
                var board = new string[5, 5];
                var textContent = request?.TextContent ?? new List<string>();
                var index = 0;

                for (int i = 0; i < 5; i++)
                {
                    for (int j = 0; j < 5; j++)
                    {
                        if (index < textContent.Count)
                        {
                            board[i, j] = textContent[index];
                        }
                        else
                        {
                            board[i, j] = $"Box {i + 1},{j + 1}";
                        }
                        index++;
                    }
                }

                // Save the board to database
                var boardName = request?.BoardName ?? $"Bingo Board {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}";
                int boardId = _bingoBoardDb.CreateBingoBoard(boardName, board);

                return Ok(new
                {
                    Success = true,
                    Message = "Bingo board created and saved to database successfully.",
                    BoardId = boardId,
                    BoardName = boardName,
                    Board = ConvertBoardTo2DArray(board)
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Success = false,
                    Message = "Error creating bingo board",
                    Error = ex.Message
                });
            }
        }

        [HttpPut("update-text")]
        public IActionResult UpdateText([FromBody] UpdateTextRequest request)
        {
            try
            {
                // Validate the request
                if (request.Row < 0 || request.Row >= 5 || request.Column < 0 || request.Column >= 5)
                {
                    return BadRequest(new
                    {
                        Success = false,
                        Message = "Invalid row or column."
                    });
                }

                if (request.BoardId <= 0)
                {
                    return BadRequest(new
                    {
                        Success = false,
                        Message = "Invalid board ID."
                    });
                }

                // Get the board and cells
                var (board, cells) = _bingoBoardDb.GetBingoBoardById(request.BoardId);

                if (board == null)
                {
                    return NotFound(new
                    {
                        Success = false,
                        Message = $"Bingo board with ID {request.BoardId} not found"
                    });
                }

                // Find the cell at the specified row and column
                var cell = cells.FirstOrDefault(c => c.Row == request.Row && c.Column == request.Column);

                if (cell == null)
                {
                    return NotFound(new
                    {
                        Success = false,
                        Message = "Cell not found at specified position"
                    });
                }

                // Update the cell text in database
                _bingoBoardDb.UpdateCellText(cell.Id, request.NewText);

                return Ok(new
                {
                    Success = true,
                    Message = "Cell text updated successfully.",
                    CellId = cell.Id,
                    Row = request.Row,
                    Column = request.Column,
                    NewText = request.NewText
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Success = false,
                    Message = "Error updating cell text",
                    Error = ex.Message
                });
            }
        }

        [HttpGet("boards")]
        public IActionResult GetAllBoards()
        {
            try
            {
                var boards = _bingoBoardDb.GetAllBingoBoards();

                return Ok(new
                {
                    Success = true,
                    Count = boards.Count,
                    Boards = boards.Select(b => new
                    {
                        Id = b.Id,
                        Name = b.Name,
                        CreatedAt = b.CreatedAt
                    }).ToList()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Success = false,
                    Message = "Error retrieving bingo boards",
                    Error = ex.Message
                });
            }
        }

        [HttpGet("board/{boardId}")]
        public IActionResult GetBoard(int boardId)
        {
            try
            {
                var (board, cells) = _bingoBoardDb.GetBingoBoardById(boardId);

                if (board == null)
                {
                    return NotFound(new
                    {
                        Success = false,
                        Message = $"Bingo board with ID {boardId} not found"
                    });
                }

                // Convert cells to 2D array format
                var boardArray = new string[5, 5];
                var markedArray = new bool[5, 5];

                foreach (var cell in cells)
                {
                    boardArray[cell.Row, cell.Column] = cell.Text;
                    markedArray[cell.Row, cell.Column] = cell.IsMarked;
                }

                return Ok(new
                {
                    Success = true,
                    Board = new
                    {
                        Id = board.Id,
                        Name = board.Name,
                        CreatedAt = board.CreatedAt,
                        Content = ConvertBoardTo2DArray(boardArray),
                        Marked = ConvertBoardTo2DArray(markedArray)
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Success = false,
                    Message = "Error retrieving bingo board",
                    Error = ex.Message
                });
            }
        }

        [HttpPost("mark-box")]
        public IActionResult MarkBox([FromBody] MarkBoxRequest request)
        {
            try
            {
                // Validate the request
                if (request.Row < 0 || request.Row >= 5 || request.Column < 0 || request.Column >= 5)
                {
                    return BadRequest(new
                    {
                        Success = false,
                        Message = "Invalid row or column."
                    });
                }

                if (request.BoardId <= 0)
                {
                    return BadRequest(new
                    {
                        Success = false,
                        Message = "Invalid board ID."
                    });
                }

                // Get the board and cells
                var (board, cells) = _bingoBoardDb.GetBingoBoardById(request.BoardId);

                if (board == null)
                {
                    return NotFound(new
                    {
                        Success = false,
                        Message = $"Bingo board with ID {request.BoardId} not found"
                    });
                }

                // Find the cell at the specified row and column
                var cell = cells.FirstOrDefault(c => c.Row == request.Row && c.Column == request.Column);

                if (cell == null)
                {
                    return NotFound(new
                    {
                        Success = false,
                        Message = "Cell not found at specified position"
                    });
                }

                // Mark/unmark the box in database
                bool newMarkedState = !cell.IsMarked; // Toggle marked state
                _bingoBoardDb.MarkCell(cell.Id, newMarkedState);

                return Ok(new
                {
                    Success = true,
                    Message = "Box marked successfully.",
                    CellId = cell.Id,
                    Row = request.Row,
                    Column = request.Column,
                    IsMarked = newMarkedState
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Success = false,
                    Message = "Error marking box",
                    Error = ex.Message
                });
            }
        }

        [HttpPost("mini-game")]
        public IActionResult MiniGame([FromBody] MiniGameResultRequest request)
        {
            if (request.Won)
            {
                return Ok(new { Message = "Mini-game won! You can mark a box." });
            }
            else
            {
                return Ok(new { Message = "Mini-game skipped." });
            }
        }


        /// <summary>
        /// Helper method to convert 2D array to jagged array for JSON serialization
        /// </summary>
        private object ConvertBoardTo2DArray<T>(T[,] board)
        {
            var result = new List<List<T>>();
            for (int i = 0; i < board.GetLength(0); i++)
            {
                var row = new List<T>();
                for (int j = 0; j < board.GetLength(1); j++)
                {
                    row.Add(board[i, j]);
                }
                result.Add(row);
            }
            return result;
        }
    }

    public static class BingoBoardState
    {
        public static string[,] Board { get; set; } = new string[5, 5];
    }

    public class UpdateTextRequest
    {
        public int BoardId { get; set; }
        public int Row { get; set; }
        public int Column { get; set; }
        public string NewText { get; set; }
    }

    public class IssueBoardRequest
    {
        public string BoardName { get; set; }
        public List<string> TextContent { get; set; }
    }

    public class MarkBoxRequest
    {
        public int BoardId { get; set; }
        public int Row { get; set; }
        public int Column { get; set; }
    }

    public class MiniGameResultRequest
    {
        public bool Won { get; set; }
    }
}