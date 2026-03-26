using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System;

namespace BingoEvent.API.Data
{
    public class BingoContext : DbContext
    {
        public BingoContext(DbContextOptions<BingoContext> options) : base(options) { }

        public DbSet<Event> Events { get; set; }
        public DbSet<WelcomePage> WelcomePages { get; set; }
        public DbSet<BingoBoard> BingoBoards { get; set; }
        public DbSet<Game> Games { get; set; }
        public DbSet<HelloWorldEntry> HelloWorldEntries { get; set; }
        public DbSet<QuestionPackage> QuestionPackages { get; set; }
        public DbSet<Question> Questions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Seed initial data
            modelBuilder.Entity<WelcomePage>().HasData(
                new WelcomePage { Id = 1, Name = "Default Welcome Page", Title = "Welcome!", Subtitle = "" }
            );

            modelBuilder.Entity<Game>().HasData(
                new Game { Id = 1, Name = "Default Game" }
            );
        }
    }

    public class Event
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public string Creator { get; set; } = "";
        public int WelcomePageId { get; set; }
        public int BingoBoardId { get; set; }
        public string GameNames { get; set; } = "[]";
        public int? QuestionPackageId { get; set; }
    }

    public class WelcomePage
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Title { get; set; } = "";
        public string Subtitle { get; set; } = "";
    }

    public class BingoBoard
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Boxes { get; set; } = "[]";
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class Game
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class HelloWorldEntry
    {
        public int Id { get; set; }
        public string Message { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class QuestionPackage
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public bool IsDefault { get; set; } = false;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class Question
    {
        public int Id { get; set; }
        public int QuestionPackageId { get; set; }
        public string QuestionText { get; set; } = "";
        public string Answer1 { get; set; } = "";
        public string Answer2 { get; set; } = "";
        public string Answer3 { get; set; } = "";
        public int CorrectAnswer { get; set; } = 1;
    }
}