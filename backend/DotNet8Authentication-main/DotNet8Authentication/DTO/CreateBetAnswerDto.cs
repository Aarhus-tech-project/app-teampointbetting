namespace DotNet8Authentication.DTO
{
    public class CreateBetAnswerDto
    {
        public Guid BetId { get; set; }
        public string Answer { get; set; }
        public int BettedPoints { get; set; }
    }
}
