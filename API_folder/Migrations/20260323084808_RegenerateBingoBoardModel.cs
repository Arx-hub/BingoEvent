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
            // No-op: columns already added by AddBingoBoardColumns migration
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // No-op: columns managed by AddBingoBoardColumns migration
        }
    }
}
