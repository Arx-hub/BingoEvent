using Microsoft.AspNetCore.Mvc;

namespace BingoEvent.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BingoController : ControllerBase
    {
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