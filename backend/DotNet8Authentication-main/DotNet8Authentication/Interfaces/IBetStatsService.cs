namespace DotNet8Authentication.Interfaces
{
    public interface IBetStatsService
    {
        Task<(int totalYes, int totalNo)> GetBetTotalsAsync(Guid betId);
    }
}