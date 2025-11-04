namespace DotNet8Authentication.Interfaces
{
    public interface IBetStatsService
    {
        Task<(int totalYesPoints, int totalNoPoints)> GetBetTotalsAsync(Guid betId);
    }
}