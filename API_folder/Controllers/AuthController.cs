using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using BingoEvent.API.Data;
using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace BingoEvent.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [EnableCors("AllowAll")]
    public class AuthController : ControllerBase
    {
        private readonly BingoContext _dbContext;

        public AuthController(BingoContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// Login endpoint - authenticate admin user
        /// </summary>
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrEmpty(request.Username) || string.IsNullOrEmpty(request.Password))
            {
                return BadRequest(new { Success = false, Message = "Username and password are required" });
            }

            var account = _dbContext.AdminAccounts
                .FirstOrDefault(a => a.Username == request.Username);

            if (account == null)
            {
                return Unauthorized(new { Success = false, Message = "Invalid username or password" });
            }

            if (!VerifyPassword(request.Password, account.PasswordHash))
            {
                return Unauthorized(new { Success = false, Message = "Invalid username or password" });
            }

            return Ok(new
            {
                Success = true,
                Message = "Login successful",
                AdminId = account.Id,
                Username = account.Username,
                IsMaster = account.IsMaster,
                Token = GenerateToken(account.Id, account.Username, account.IsMaster)
            });
        }

        /// <summary>
        /// Get all admin accounts (master only)
        /// </summary>
        [HttpGet("admin/all")]
        public IActionResult GetAllAdmins([FromQuery] int adminId)
        {
            var account = _dbContext.AdminAccounts.FirstOrDefault(a => a.Id == adminId);
            if (account == null || !account.IsMaster)
            {
                return Forbid();
            }

            var admins = _dbContext.AdminAccounts
                .OrderByDescending(a => a.IsMaster)
                .ThenByDescending(a => a.CreatedAt)
                .Select(a => new
                {
                    a.Id,
                    a.Username,
                    a.IsMaster,
                    a.CreatedAt,
                    a.UpdatedAt
                })
                .ToList();

            return Ok(new { Success = true, Admins = admins });
        }

        /// <summary>
        /// Create a new admin account (master only)
        /// </summary>
        [HttpPost("admin/create")]
        public IActionResult CreateAdmin([FromBody] CreateAdminRequest request, [FromQuery] int adminId)
        {
            var requester = _dbContext.AdminAccounts.FirstOrDefault(a => a.Id == adminId);
            if (requester == null || !requester.IsMaster)
            {
                return Forbid();
            }

            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { Success = false, Message = "Username and password are required" });
            }

            if (request.Username.Length < 3)
            {
                return BadRequest(new { Success = false, Message = "Username must be at least 3 characters" });
            }

            if (request.Password.Length < 6)
            {
                return BadRequest(new { Success = false, Message = "Password must be at least 6 characters" });
            }

            // Check if username already exists
            if (_dbContext.AdminAccounts.Any(a => a.Username == request.Username))
            {
                return BadRequest(new { Success = false, Message = "Username already exists" });
            }

            var newAccount = new AdminAccount
            {
                Username = request.Username,
                PasswordHash = HashPassword(request.Password),
                IsMaster = false,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _dbContext.AdminAccounts.Add(newAccount);
            _dbContext.SaveChanges();

            return Ok(new
            {
                Success = true,
                Message = "Admin account created successfully",
                AdminId = newAccount.Id,
                Username = newAccount.Username
            });
        }

        /// <summary>
        /// Update an admin account (master only)
        /// </summary>
        [HttpPut("admin/update")]
        public IActionResult UpdateAdmin([FromBody] UpdateAdminRequest request, [FromQuery] int adminId)
        {
            var requester = _dbContext.AdminAccounts.FirstOrDefault(a => a.Id == adminId);
            if (requester == null || !requester.IsMaster)
            {
                return Forbid();
            }

            var account = _dbContext.AdminAccounts.FirstOrDefault(a => a.Id == request.Id);
            if (account == null)
            {
                return NotFound(new { Success = false, Message = "Account not found" });
            }

            // Prevent updating master account
            if (account.IsMaster)
            {
                return BadRequest(new { Success = false, Message = "Cannot modify the master account" });
            }

            // Update username if provided and different
            if (!string.IsNullOrWhiteSpace(request.Username) && request.Username != account.Username)
            {
                if (request.Username.Length < 3)
                {
                    return BadRequest(new { Success = false, Message = "Username must be at least 3 characters" });
                }

                if (_dbContext.AdminAccounts.Any(a => a.Username == request.Username && a.Id != request.Id))
                {
                    return BadRequest(new { Success = false, Message = "Username already exists" });
                }

                account.Username = request.Username;
            }

            // Update password if provided
            if (!string.IsNullOrWhiteSpace(request.Password))
            {
                if (request.Password.Length < 6)
                {
                    return BadRequest(new { Success = false, Message = "Password must be at least 6 characters" });
                }

                account.PasswordHash = HashPassword(request.Password);
            }

            account.UpdatedAt = DateTime.UtcNow;
            _dbContext.SaveChanges();

            return Ok(new
            {
                Success = true,
                Message = "Admin account updated successfully",
                AdminId = account.Id,
                Username = account.Username
            });
        }

        /// <summary>
        /// Delete an admin account (master only)
        /// </summary>
        [HttpDelete("admin/delete/{id}")]
        public IActionResult DeleteAdmin(int id, [FromQuery] int adminId)
        {
            var requester = _dbContext.AdminAccounts.FirstOrDefault(a => a.Id == adminId);
            if (requester == null || !requester.IsMaster)
            {
                return Forbid();
            }

            var account = _dbContext.AdminAccounts.FirstOrDefault(a => a.Id == id);
            if (account == null)
            {
                return NotFound(new { Success = false, Message = "Account not found" });
            }

            // Prevent deleting master account
            if (account.IsMaster)
            {
                return BadRequest(new { Success = false, Message = "Cannot delete the master account" });
            }

            _dbContext.AdminAccounts.Remove(account);
            _dbContext.SaveChanges();

            return Ok(new
            {
                Success = true,
                Message = "Admin account deleted successfully"
            });
        }

        /// <summary>
        /// Verify current admin session
        /// </summary>
        [HttpPost("verify")]
        public IActionResult VerifySession([FromQuery] int adminId)
        {
            var account = _dbContext.AdminAccounts.FirstOrDefault(a => a.Id == adminId);
            if (account == null)
            {
                return Unauthorized(new { Success = false, Message = "Session invalid" });
            }

            return Ok(new
            {
                Success = true,
                AdminId = account.Id,
                Username = account.Username,
                IsMaster = account.IsMaster
            });
        }

        private string HashPassword(string password)
        {
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(password));
        }

        private bool VerifyPassword(string password, string hash)
        {
            var hashOfInput = Convert.ToBase64String(Encoding.UTF8.GetBytes(password));
            return hashOfInput == hash;
        }

        private string GenerateToken(int adminId, string username, bool isMaster)
        {
            // Simple token format: adminId|username|isMaster|timestamp
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            var tokenData = $"{adminId}|{username}|{isMaster}|{timestamp}";
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(tokenData));
        }
    }

    public class LoginRequest
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }

    public class CreateAdminRequest
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }

    public class UpdateAdminRequest
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
    }
}
