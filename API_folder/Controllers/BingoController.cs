using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using BingoEvent.API.Data;
using System;
using System.Linq;
using System.Threading.Tasks;

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
}