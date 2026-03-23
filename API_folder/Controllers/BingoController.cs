using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using BingoEvent.API.Data;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace BingoEvent.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [EnableCors("AllowAll")]
    public class BingoController : ControllerBase
    {
        private readonly BingoContext _dbContext;

        public BingoController(BingoContext dbContext)
        {
            _dbContext = dbContext;
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
        public IActionResult IssueBoard()
        {
            // Generate a 5x5 bingo board with placeholder text
            var board = new string[5, 5];
            for (int i = 0; i < 5; i++)
            {
                for (int j = 0; j < 5; j++)
                {
                    board[i, j] = $"Box {i + 1},{j + 1}";
                }
            }

            // Store the board in memory
            BingoBoardState.Board = board;

            return Ok(new { Message = "Bingo board issued successfully.", Board = board });
        }

        [HttpPut("update-text")]
        public IActionResult UpdateText([FromBody] UpdateTextRequest request)
        {
            // Validate the request
            if (request.Row < 0 || request.Row >= 5 || request.Column < 0 || request.Column >= 5)
            {
                return BadRequest(new { Message = "Invalid row or column." });
            }

            // Update the text on the board
            BingoBoardState.Board[request.Row, request.Column] = request.NewText;

            return Ok(new { Message = "Text fields updated successfully.", Board = BingoBoardState.Board });
        }

        [HttpGet("board")]
        public IActionResult GetBoard()
        {
            // Return the current bingo board
            return Ok(new { Board = BingoBoardState.Board });
        }

        [HttpPost("mark-box")]
        public IActionResult MarkBox([FromBody] MarkBoxRequest request)
        {
            // Validate the request
            if (request.Row < 0 || request.Row >= 5 || request.Column < 0 || request.Column >= 5)
            {
                return BadRequest(new { Message = "Invalid row or column." });
            }

            // Mark the box as checked
            BingoBoardState.Board[request.Row, request.Column] = "Checked";

            return Ok(new { Message = "Box marked successfully.", Board = BingoBoardState.Board });
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
        /// OPTIONS endpoint for CORS preflight requests
        /// </summary>
        [HttpOptions("hello-world")]
        public IActionResult OptionsHelloWorld()
        {
            return Ok();
        }

        /// <summary>
        /// POST endpoint to write "Hello World" to the database
        /// Automatically creates the HelloWorldEntries table if it doesn't exist
        /// </summary>
        [HttpPost("hello-world")]
        public async Task<IActionResult> WriteHelloWorld()
        {
            try
            {
                // Ensure database is created
                await _dbContext.Database.EnsureCreatedAsync();

                // Create new Hello World entry
                var entry = new HelloWorldEntry
                {
                    Message = "Hello World",
                    CreatedAt = DateTime.UtcNow
                };

                // Add to database
                _dbContext.HelloWorldEntries.Add(entry);
                await _dbContext.SaveChangesAsync();

                return Ok(new
                {
                    Success = true,
                    Message = "Hello World written to database successfully",
                    EntryId = entry.Id,
                    CreatedAt = entry.CreatedAt,
                    Message_Content = entry.Message
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Success = false,
                    Message = "Error writing to database",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// GET endpoint to retrieve all "Hello World" entries from the database
        /// </summary>
        [HttpGet("hello-world")]
        public async Task<IActionResult> GetHelloWorlds()
        {
            try
            {
                // Ensure database is created
                await _dbContext.Database.EnsureCreatedAsync();

                // Get all entries
                var entries = _dbContext.HelloWorldEntries
                    .OrderByDescending(e => e.CreatedAt)
                    .ToList();

                return Ok(new
                {
                    Success = true,
                    Count = entries.Count,
                    Entries = entries.Select(e => new
                    {
                        Id = e.Id,
                        Message = e.Message,
                        CreatedAt = e.CreatedAt
                    }).ToList()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Success = false,
                    Message = "Error retrieving from database",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// POST endpoint to save a bingo board to the database
        /// </summary>
        [HttpPost("save-board")]
        public async Task<IActionResult> SaveBoard([FromBody] SaveBoardRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Name))
                    return BadRequest(new { Success = false, Message = "Board name is required." });

                var board = new BingoBoard { Name = request.Name };
                _dbContext.BingoBoards.Add(board);
                await _dbContext.SaveChangesAsync();

                return Ok(new { Success = true, Message = "Board saved.", BoardId = board.Id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error saving board", Error = ex.Message });
            }
        }

        /// <summary>
        /// GET endpoint to retrieve all bingo boards
        /// </summary>
        [HttpGet("boards")]
        public async Task<IActionResult> GetBoards()
        {
            try
            {
                var boards = await _dbContext.BingoBoards.ToListAsync();
                return Ok(new { Success = true, Count = boards.Count, Boards = boards });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving boards", Error = ex.Message });
            }
        }

        /// <summary>
        /// GET endpoint to retrieve a single bingo board by ID
        /// </summary>
        [HttpGet("board/{id}")]
        public async Task<IActionResult> GetBoard(int id)
        {
            try
            {
                var board = await _dbContext.BingoBoards.FindAsync(id);
                if (board == null)
                    return NotFound(new { Success = false, Message = "Board not found." });

                return Ok(new { Success = true, Board = board });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving board", Error = ex.Message });
            }
        }

        /// <summary>
        /// PUT endpoint to update a bingo board
        /// </summary>
        [HttpPut("board/{id}")]
        public async Task<IActionResult> UpdateBoard(int id, [FromBody] UpdateBoardRequest request)
        {
            try
            {
                var board = await _dbContext.BingoBoards.FindAsync(id);
                if (board == null)
                    return NotFound(new { Success = false, Message = "Board not found." });

                if (!string.IsNullOrWhiteSpace(request.Name))
                    board.Name = request.Name;

                _dbContext.BingoBoards.Update(board);
                await _dbContext.SaveChangesAsync();

                return Ok(new { Success = true, Message = "Board updated successfully.", Board = board });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error updating board", Error = ex.Message });
            }
        }

        /// <summary>
        /// DELETE endpoint to delete a bingo board
        /// </summary>
        [HttpDelete("board/{id}")]
        public async Task<IActionResult> DeleteBoard(int id)
        {
            try
            {
                var board = await _dbContext.BingoBoards.FindAsync(id);
                if (board == null)
                    return NotFound(new { Success = false, Message = "Board not found." });

                _dbContext.BingoBoards.Remove(board);
                await _dbContext.SaveChangesAsync();

                return Ok(new { Success = true, Message = "Board deleted successfully." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error deleting board", Error = ex.Message });
            }
        }
    }

    public static class BingoBoardState
    {
        public static string[,] Board { get; set; } = new string[5, 5];
    }

    public class UpdateTextRequest
    {
        public int Row { get; set; }
        public int Column { get; set; }
        public string NewText { get; set; }
    }

    public class MarkBoxRequest
    {
        public int Row { get; set; }
        public int Column { get; set; }
    }

    public class MiniGameResultRequest
    {
        public bool Won { get; set; }
    }

    public class SaveBoardRequest
    {
        public string Name { get; set; }
    }

    public class UpdateBoardRequest
    {
        public string Name { get; set; }
    }
}