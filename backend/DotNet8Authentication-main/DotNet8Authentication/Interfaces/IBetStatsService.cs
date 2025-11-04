namespace DotNet8Authentication.Interfaces
{
    public interface IBetStatsService
    {
        Task<(int totalYes, int totalNo, int totalAll)> GetBetTotalsAsync(Guid betId);
    }
}