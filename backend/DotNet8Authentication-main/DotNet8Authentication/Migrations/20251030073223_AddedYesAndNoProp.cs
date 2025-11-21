using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DotNet8Authentication.Migrations
{
    /// <inheritdoc />
    public partial class AddedYesAndNoProp : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "BettedPointsNo",
                table: "Bets",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "BettedPointsYes",
                table: "Bets",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BettedPointsNo",
                table: "Bets");

            migrationBuilder.DropColumn(
                name: "BettedPointsYes",
                table: "Bets");
        }
    }
}
