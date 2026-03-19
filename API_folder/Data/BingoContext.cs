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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Seed initial data
            modelBuilder.Entity<WelcomePage>().HasData(
                new WelcomePage { Id = 1, Name = "Default Welcome Page" }
            );

            modelBuilder.Entity<BingoBoard>().HasData(
                new BingoBoard { Id = 1, Name = "Default Bingo Board" }
            );

            modelBuilder.Entity<Game>().HasData(
                new Game { Id = 1, Name = "Default Game" }
            );
        }
    }

    public class Event
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Creator { get; set; }
        public int WelcomePageId { get; set; }
        public WelcomePage WelcomePage { get; set; }
        public int BingoBoardId { get; set; }
        public BingoBoard BingoBoard { get; set; }
        public List<Game> Games { get; set; } = new();
    }

    public class WelcomePage
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class BingoBoard
    {
        public int Id { get; set; }
        public string Name { get; set; }
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
}