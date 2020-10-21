using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Microsoft.Azure.Cosmos;

using cart.Models;

namespace cart.Data
{

    public interface ICartCRUDService
    {
        Task<IEnumerable<Cart>> GetItemsAsync(string query);
        Task<Cart> GetItemAsync(string id);
        Task AddItemAsync(Cart item);
        Task UpdateItemAsync(string id, Cart item);
        Task DeleteItemAsync(string id);
    }
    
    public class CartCRUDService : ICartCRUDService
    {
        private Container _container;

        public CartCRUDService(
            CosmosClient dbClient,
            string databaseName,
            string containerName)
        {
            this._container = dbClient.GetContainer(databaseName, containerName);
        }

        public async Task AddItemAsync(Cart item)
        {
            await this._container.UpsertItemAsync<Cart>(item, new PartitionKey(item.Id));
        }

        public async Task DeleteItemAsync(string id)
        {
            await this._container.DeleteItemAsync<Cart>(id, new PartitionKey(id));
        }

        public async Task<Cart> GetItemAsync(string id)
        {
            try
            {
                ItemResponse<Cart> response = await this._container.ReadItemAsync<Cart>(id, new PartitionKey(id));
                return response.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                return null;
            }

        }

        public async Task<IEnumerable<Cart>> GetItemsAsync(string queryString)
        {
            var query = this._container.GetItemQueryIterator<Cart>(new QueryDefinition(queryString));
            List<Cart> results = new List<Cart>();
            while (query.HasMoreResults)
            {
                var response = await query.ReadNextAsync();

                results.AddRange(response.ToList());
            }

            return results;
        }

        public async Task UpdateItemAsync(string id, Cart item)
        {
            await this._container.UpsertItemAsync<Cart>(item, new PartitionKey(id));
        }
    }
}    

