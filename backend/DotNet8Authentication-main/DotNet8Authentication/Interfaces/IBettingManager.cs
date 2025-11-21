namespace DotNet8Authentication.Interfaces
{
    public interface IBettingManager
    {
        Task<bool> EvaluateAndPayoutBetAsync(Guid betId, string winningAnswer);
    }
}
