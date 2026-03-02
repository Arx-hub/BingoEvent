using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace APIfolder.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BingoBoards",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Name = table.Column<string>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BingoBoards", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "WelcomePages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Name = table.Column<string>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WelcomePages", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Name = table.Column<string>(type: "TEXT", nullable: true),
                    Creator = table.Column<string>(type: "TEXT", nullable: true),
                    WelcomePageId = table.Column<int>(type: "INTEGER", nullable: false),
                    BingoBoardId = table.Column<int>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Events_BingoBoards_BingoBoardId",
                        column: x => x.BingoBoardId,
                        principalTable: "BingoBoards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Events_WelcomePages_WelcomePageId",
                        column: x => x.WelcomePageId,
                        principalTable: "WelcomePages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Games",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Name = table.Column<string>(type: "TEXT", nullable: true),
                    EventId = table.Column<int>(type: "INTEGER", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Games", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Games_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id");
                });

            migrationBuilder.InsertData(
                table: "BingoBoards",
                columns: new[] { "Id", "Name" },
                values: new object[] { 1, "Default Bingo Board" });

            migrationBuilder.InsertData(
                table: "Games",
                columns: new[] { "Id", "EventId", "Name" },
                values: new object[] { 1, null, "Default Game" });

            migrationBuilder.InsertData(
                table: "WelcomePages",
                columns: new[] { "Id", "Name" },
                values: new object[] { 1, "Default Welcome Page" });

            migrationBuilder.CreateIndex(
                name: "IX_Events_BingoBoardId",
                table: "Events",
                column: "BingoBoardId");

            migrationBuilder.CreateIndex(
                name: "IX_Events_WelcomePageId",
                table: "Events",
                column: "WelcomePageId");

            migrationBuilder.CreateIndex(
                name: "IX_Games_EventId",
                table: "Games",
                column: "EventId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Games");

            migrationBuilder.DropTable(
                name: "Events");

            migrationBuilder.DropTable(
                name: "BingoBoards");

            migrationBuilder.DropTable(
                name: "WelcomePages");
        }
    }
}
