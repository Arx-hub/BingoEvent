using Microsoft.EntityFrameworkCore.Migrations;
using System;

#nullable disable

namespace APIfolder.Migrations
{
    /// <inheritdoc />
    public partial class RegenerateBingoBoardModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Boxes",
                table: "BingoBoards",
                type: "TEXT",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "BingoBoards",
                type: "TEXT",
                nullable: false,
                defaultValue: new DateTime(2026, 3, 23, 0, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "BingoBoards",
                type: "TEXT",
                nullable: false,
                defaultValue: new DateTime(2026, 3, 23, 0, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "BingoBoards",
                type: "INTEGER",
                nullable: false,
                defaultValue: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Boxes",
                table: "BingoBoards");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "BingoBoards");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "BingoBoards");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "BingoBoards");
        }
    }
}
