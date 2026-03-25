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
        public async Task<IActionResult> SaveBoard([FromBody] SaveBoardRequest? request)
        {
            try
            {
                Console.WriteLine($"[SaveBoard] Received request. Request is null: {request == null}");
                
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.ToDictionary(
                        kvp => kvp.Key,
                        kvp => kvp.Value?.Errors.Select(e => e.ErrorMessage).ToArray()
                    );
                    Console.WriteLine($"[SaveBoard] Validation errors: {System.Text.Json.JsonSerializer.Serialize(errors)}");
                    return BadRequest(new { Success = false, Message = "Validation failed", Errors = errors });
                }

                if (request == null)
                    return BadRequest(new { Success = false, Message = "Request body is null." });

                Console.WriteLine($"[SaveBoard] Name: {request.Name}, Id: {request.Id}, Boxes count: {request.Boxes?.Count ?? 0}");
                
                if (string.IsNullOrWhiteSpace(request.Name))
                    return BadRequest(new { Success = false, Message = "Board name is required." });

                var boxesJson = request.Boxes != null
                    ? System.Text.Json.JsonSerializer.Serialize(request.Boxes)
                    : "[]";

                BingoBoard board;
                if (request.Id.HasValue)
                {
                    board = await _dbContext.BingoBoards.FindAsync(request.Id.Value);
                    if (board == null)
                        return NotFound(new { Success = false, Message = "Board not found." });

                    board.Name = request.Name;
                    board.Boxes = boxesJson;
                    board.IsActive = request.IsActive;
                    board.UpdatedAt = DateTime.UtcNow;
                    _dbContext.BingoBoards.Update(board);
                }
                else
                {
                    board = new BingoBoard
                    {
                        Name = request.Name,
                        Boxes = boxesJson,
                        IsActive = request.IsActive,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    _dbContext.BingoBoards.Add(board);
                }

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
                var result = boards.Select(b => new
                {
                    b.Id,
                    b.Name,
                    Boxes = string.IsNullOrEmpty(b.Boxes)
                        ? new List<string>()
                        : System.Text.Json.JsonSerializer.Deserialize<List<string>>(b.Boxes),
                    b.CreatedAt,
                    b.UpdatedAt,
                    b.IsActive
                }).ToList();
                return Ok(new { Success = true, Count = boards.Count, Boards = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving boards", Error = ex.Message });
            }
        }

        /// <summary>
        /// GET endpoint to retrieve a single bingo board by ID
        /// </summary>
        [HttpGet("boards/{id}")]
        public async Task<IActionResult> GetBoard(int id)
        {
            try
            {
                var board = await _dbContext.BingoBoards.FindAsync(id);
                if (board == null)
                    return NotFound(new { Success = false, Message = "Board not found." });

                var result = new
                {
                    board.Id,
                    board.Name,
                    Boxes = string.IsNullOrEmpty(board.Boxes)
                        ? new List<string>()
                        : System.Text.Json.JsonSerializer.Deserialize<List<string>>(board.Boxes),
                    board.CreatedAt,
                    board.UpdatedAt,
                    board.IsActive
                };
                return Ok(new { Success = true, Board = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving board", Error = ex.Message });
            }
        }

        /// <summary>
        /// GET endpoint to load a bingo board by ID (used by Flutter admin app)
        /// </summary>
        [HttpGet("load-board/{id}")]
        public async Task<IActionResult> LoadBoard(int id)
        {
            try
            {
                var board = await _dbContext.BingoBoards.FindAsync(id);
                if (board == null)
                    return NotFound(new { Success = false, Message = "Board not found." });

                return Ok(new
                {
                    board.Id,
                    board.Name,
                    Boxes = string.IsNullOrEmpty(board.Boxes)
                        ? new List<string>()
                        : System.Text.Json.JsonSerializer.Deserialize<List<string>>(board.Boxes),
                    board.CreatedAt,
                    board.UpdatedAt,
                    board.IsActive
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error loading board", Error = ex.Message });
            }
        }

        /// <summary>
        /// PUT endpoint to update a bingo board
        /// </summary>
        [HttpPut("boards/{id}")]
        public async Task<IActionResult> UpdateBoard(int id, [FromBody] UpdateBoardRequest request)
        {
            try
            {
                var board = await _dbContext.BingoBoards.FindAsync(id);
                if (board == null)
                    return NotFound(new { Success = false, Message = "Board not found." });

                if (!string.IsNullOrWhiteSpace(request.Name))
                    board.Name = request.Name;
                if (request.Boxes != null)
                    board.Boxes = System.Text.Json.JsonSerializer.Serialize(request.Boxes);
                board.UpdatedAt = DateTime.UtcNow;

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
        [HttpDelete("boards/{id}")]
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

        // ==================== Welcome Page Endpoints ====================

        /// <summary>
        /// GET endpoint to retrieve all welcome pages
        /// </summary>
        [HttpGet("welcome-pages")]
        public async Task<IActionResult> GetWelcomePages()
        {
            try
            {
                var pages = await _dbContext.WelcomePages.ToListAsync();
                var result = pages.Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.Title,
                    p.Subtitle
                }).ToList();
                return Ok(new { Success = true, Count = pages.Count, WelcomePages = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving welcome pages", Error = ex.Message });
            }
        }

        /// <summary>
        /// GET endpoint to retrieve a single welcome page by ID
        /// </summary>
        [HttpGet("welcome-pages/{id}")]
        public async Task<IActionResult> GetWelcomePage(int id)
        {
            try
            {
                var page = await _dbContext.WelcomePages.FindAsync(id);
                if (page == null)
                    return NotFound(new { Success = false, Message = "Welcome page not found." });

                return Ok(new { Success = true, WelcomePage = new { page.Id, page.Name, page.Title, page.Subtitle } });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving welcome page", Error = ex.Message });
            }
        }

        /// <summary>
        /// POST endpoint to save a welcome page (create or update)
        /// </summary>
        [HttpPost("welcome-pages")]
        public async Task<IActionResult> SaveWelcomePage([FromBody] SaveWelcomePageRequest? request)
        {
            try
            {
                if (request == null)
                    return BadRequest(new { Success = false, Message = "Request body is null." });

                if (string.IsNullOrWhiteSpace(request.Name))
                    return BadRequest(new { Success = false, Message = "Welcome page name is required." });

                WelcomePage? page;
                if (request.Id.HasValue)
                {
                    page = await _dbContext.WelcomePages.FindAsync(request.Id.Value);
                    if (page == null)
                        return NotFound(new { Success = false, Message = "Welcome page not found." });

                    page.Name = request.Name;
                    page.Title = request.Title ?? "";
                    page.Subtitle = request.Subtitle ?? "";
                    _dbContext.WelcomePages.Update(page);
                }
                else
                {
                    page = new WelcomePage
                    {
                        Name = request.Name,
                        Title = request.Title ?? "",
                        Subtitle = request.Subtitle ?? "",
                    };
                    _dbContext.WelcomePages.Add(page);
                }

                await _dbContext.SaveChangesAsync();

                return Ok(new { Success = true, Message = "Welcome page saved.", WelcomePageId = page.Id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error saving welcome page", Error = ex.Message });
            }
        }

        /// <summary>
        /// DELETE endpoint to delete a welcome page
        /// </summary>
        [HttpDelete("welcome-pages/{id}")]
        public async Task<IActionResult> DeleteWelcomePage(int id)
        {
            try
            {
                var page = await _dbContext.WelcomePages.FindAsync(id);
                if (page == null)
                    return NotFound(new { Success = false, Message = "Welcome page not found." });

                _dbContext.WelcomePages.Remove(page);
                await _dbContext.SaveChangesAsync();

                return Ok(new { Success = true, Message = "Welcome page deleted successfully." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error deleting welcome page", Error = ex.Message });
            }
        }

        // ==================== Event Endpoints ====================

        /// <summary>
        /// GET endpoint to retrieve all events
        /// </summary>
        [HttpGet("events")]
        public async Task<IActionResult> GetEvents()
        {
            try
            {
                var events = await _dbContext.Events.ToListAsync();
                var result = events.Select(e => new
                {
                    e.Id,
                    e.Name,
                    e.Creator,
                    e.WelcomePageId,
                    e.BingoBoardId,
                    GameNames = string.IsNullOrEmpty(e.GameNames)
                        ? new List<string>()
                        : System.Text.Json.JsonSerializer.Deserialize<List<string>>(e.GameNames)
                }).ToList();
                return Ok(new { Success = true, Count = events.Count, Events = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving events", Error = ex.Message });
            }
        }

        /// <summary>
        /// GET endpoint to retrieve a single event by ID
        /// </summary>
        [HttpGet("events/{id}")]
        public async Task<IActionResult> GetEvent(int id)
        {
            try
            {
                var evt = await _dbContext.Events.FindAsync(id);
                if (evt == null)
                    return NotFound(new { Success = false, Message = "Event not found." });

                return Ok(new
                {
                    Success = true,
                    Event = new
                    {
                        evt.Id,
                        evt.Name,
                        evt.Creator,
                        evt.WelcomePageId,
                        evt.BingoBoardId,
                        GameNames = string.IsNullOrEmpty(evt.GameNames)
                            ? new List<string>()
                            : System.Text.Json.JsonSerializer.Deserialize<List<string>>(evt.GameNames)
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error retrieving event", Error = ex.Message });
            }
        }

        /// <summary>
        /// POST endpoint to save an event (create or update)
        /// </summary>
        [HttpPost("events")]
        public async Task<IActionResult> SaveEvent([FromBody] SaveEventRequest? request)
        {
            try
            {
                if (request == null)
                    return BadRequest(new { Success = false, Message = "Request body is null." });

                if (string.IsNullOrWhiteSpace(request.Name))
                    return BadRequest(new { Success = false, Message = "Event name is required." });

                var gameNamesJson = request.GameNames != null
                    ? System.Text.Json.JsonSerializer.Serialize(request.GameNames)
                    : "[]";

                Event evt;
                if (request.Id.HasValue)
                {
                    evt = await _dbContext.Events.FindAsync(request.Id.Value);
                    if (evt == null)
                        return NotFound(new { Success = false, Message = "Event not found." });

                    evt.Name = request.Name;
                    evt.Creator = request.Creator ?? "";
                    evt.WelcomePageId = request.WelcomePageId;
                    evt.BingoBoardId = request.BingoBoardId;
                    evt.GameNames = gameNamesJson;
                    _dbContext.Events.Update(evt);
                }
                else
                {
                    evt = new Event
                    {
                        Name = request.Name,
                        Creator = request.Creator ?? "",
                        WelcomePageId = request.WelcomePageId,
                        BingoBoardId = request.BingoBoardId,
                        GameNames = gameNamesJson,
                    };
                    _dbContext.Events.Add(evt);
                }

                await _dbContext.SaveChangesAsync();

                return Ok(new { Success = true, Message = "Event saved.", EventId = evt.Id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error saving event", Error = ex.Message });
            }
        }

        /// <summary>
        /// DELETE endpoint to delete an event
        /// </summary>
        [HttpDelete("events/{id}")]
        public async Task<IActionResult> DeleteEvent(int id)
        {
            try
            {
                var evt = await _dbContext.Events.FindAsync(id);
                if (evt == null)
                    return NotFound(new { Success = false, Message = "Event not found." });

                _dbContext.Events.Remove(evt);
                await _dbContext.SaveChangesAsync();

                return Ok(new { Success = true, Message = "Event deleted successfully." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Success = false, Message = "Error deleting event", Error = ex.Message });
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
        public int? Id { get; set; }
        public string? Name { get; set; }
        public List<string>? Boxes { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class UpdateBoardRequest
    {
        public string? Name { get; set; }
        public List<string>? Boxes { get; set; }
    }

    public class SaveWelcomePageRequest
    {
        public int? Id { get; set; }
        public string? Name { get; set; }
        public string? Title { get; set; }
        public string? Subtitle { get; set; }
    }

    public class SaveEventRequest
    {
        public int? Id { get; set; }
        public string? Name { get; set; }
        public string? Creator { get; set; }
        public int WelcomePageId { get; set; }
        public int BingoBoardId { get; set; }
        public List<string>? GameNames { get; set; }
    }
}