using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Microsoft.Azure.Cosmos;

using catalog.Models;

namespace catalog.Data
{

    public interface ICatalogItemCRUDService
    {
        Task<IEnumerable<CatalogItem>> GetItemsAsync(string query);
        Task<CatalogItem> GetItemAsync(string id);
        Task AddItemAsync(CatalogItem item);
        Task UpdateItemAsync(string id, CatalogItem item);
        Task DeleteItemAsync(string id);
    }
    
    public class CatalogItemCRUDService : ICatalogItemCRUDService
    {
        private Container _container;

        public CatalogItemCRUDService(
            CosmosClient dbClient,
            string databaseName,
            string containerName)
        {
            this._container = dbClient.GetContainer(databaseName, containerName);
        }

        public async Task AddItemAsync(CatalogItem item)
        {
            await this._container.UpsertItemAsync<CatalogItem>(item, new PartitionKey(item.Id));
        }

        public async Task DeleteItemAsync(string id)
        {
            await this._container.DeleteItemAsync<CatalogItem>(id, new PartitionKey(id));
        }

        public async Task<CatalogItem> GetItemAsync(string id)
        {
            try
            {
                ItemResponse<CatalogItem> response = await this._container.ReadItemAsync<CatalogItem>(id, new PartitionKey(id));
                return response.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                return null;
            }

        }

        public async Task<IEnumerable<CatalogItem>> GetItemsAsync(string queryString)
        {
            var query = this._container.GetItemQueryIterator<CatalogItem>(new QueryDefinition(queryString));
            List<CatalogItem> results = new List<CatalogItem>();
            while (query.HasMoreResults)
            {
                var response = await query.ReadNextAsync();

                results.AddRange(response.ToList());
            }

            return results;
        }

        public async Task UpdateItemAsync(string id, CatalogItem item)
        {
            await this._container.UpsertItemAsync<CatalogItem>(item, new PartitionKey(id));
        }
    }
}    

