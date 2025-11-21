namespace DotNet8Authentication.Models
{
    public class BetAnswer
    {
        public Guid BetAnswerId { get; set; }
        public Guid BetId { get; set; }
        public Guid UserId { get; set; }
        public string Answer { get; set; }
        public DateTime SubmittedAt { get; set; }
        public int BettedPoints { get; set; }
    }
}
