using Microsoft.AspNetCore.SignalR;

namespace DotNet8Authentication.Hubs
{
    public class BetHub : Hub
    {
        public override async Task OnConnectedAsync()
        {
            await base.OnConnectedAsync();
        }
    }
}
