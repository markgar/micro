using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

using catalog.Data;
using catalog.Models;

namespace catalog.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CatalogController : ControllerBase
    {

        private readonly ILogger<CatalogController> _logger;
        private readonly ICatalogItemCRUDService _cosmosDbService;

        public CatalogController(ILogger<CatalogController> logger, ICatalogItemCRUDService cosmosDbService)
        {
            _logger = logger;
            _cosmosDbService = cosmosDbService;
        }

        [HttpGet]
        public async Task<IEnumerable<CatalogItem>> Get()
        {
            return await _cosmosDbService.GetItemsAsync("SELECT * FROM c");
        }


        [HttpGet("{Id}")]
        public async Task<ActionResult<CatalogItem>> GetById(string Id)
        {
            if (Id == null)
            {
                return BadRequest();
            }

            CatalogItem item = await _cosmosDbService.GetItemAsync(Id);
            if (item == null)
            {
                return new NotFoundResult();
            }
            else
            {
                return await _cosmosDbService.GetItemAsync(Id);
            }
        }

        [HttpPost]
        public async Task<ActionResult> Post(CatalogItem Item)
        {
            Item.Id = Guid.NewGuid().ToString();
            await _cosmosDbService.AddItemAsync(Item);
            return new OkObjectResult(Item);
        }

        [HttpDelete("{Id}")]
        public async Task<ActionResult> Delete(string Id)
        {
            if (Id == null)
            {
                return BadRequest();
            }

            CatalogItem item = await _cosmosDbService.GetItemAsync(Id);
            if (item == null)
            {
                return NotFound();
            }
            else
            {
                await _cosmosDbService.DeleteItemAsync(Id);
                return new OkResult();
            }
        }


    }
}
