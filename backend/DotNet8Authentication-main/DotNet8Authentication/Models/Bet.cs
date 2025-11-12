namespace DotNet8Authentication.Models
{
    public class Bet
    {
        public Guid BetId { get; set; }
        public Guid UserId { get; set; }
        public string Subject { get; set; }
        public DateTime Deadline { get; set; }
        public string? CorrectAnswer { get; set; }
        public bool IsDeadlineNotified { get; set; } = false;
    }
}
