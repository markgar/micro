using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

using cart.Data;
using cart.Models;
using System.Net.Http;
using Newtonsoft.Json;

namespace cart.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CartController : ControllerBase
    {
        static readonly HttpClient client = new HttpClient();
        private readonly ILogger<CartController> _logger;
        private readonly ICartCRUDService _cosmosDbService;
        public IConfiguration _configuration { get; }

        public CartController(ILogger<CartController> logger, ICartCRUDService cosmosDbService, IConfiguration configuration)
        {
            _logger = logger;
            _cosmosDbService = cosmosDbService;
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<IEnumerable<Cart>> Get()
        {
            return await _cosmosDbService.GetItemsAsync("SELECT * FROM c");
        }


        [HttpGet("{Id}")]
        public async Task<ActionResult<Cart>> GetById(string Id)
        {
            if (Id == null)
            {
                return BadRequest();
            }

            Cart cart = await _cosmosDbService.GetItemAsync(Id);
            if (cart == null)
            {
                return new NotFoundResult();
            }
            else
            {
                return await _cosmosDbService.GetItemAsync(Id);
            }
        }

        [HttpPost]
        public async Task<ActionResult> Post(Cart Cart)
        {
            Cart.Id = Guid.NewGuid().ToString();
            await _cosmosDbService.AddItemAsync(Cart);
            return new OkObjectResult(Cart);
        }


        [HttpPost("{CartId}/AddItemToCart/{CatalogItemId}")]
        public async Task<ActionResult> AddItemToCart(string CartId, string CatalogItemId)
        {
            string baseUrl = _configuration.GetSection("CatalogItemServiceUrl").Value;
            if (!baseUrl.EndsWith("/"))
            {
                baseUrl += "/";
            }
            string uri = $"{baseUrl}catalog/{CatalogItemId}";
            HttpResponseMessage response = await client.GetAsync(uri);
            response.EnsureSuccessStatusCode();
            var itemToAdd = JsonConvert.DeserializeObject<CatalogItem>( await response.Content.ReadAsStringAsync());

            Cart cart = await _cosmosDbService.GetItemAsync(CartId);

            cart.Items.Add(itemToAdd);

            await _cosmosDbService.UpdateItemAsync(CartId, cart);

            return new OkObjectResult(cart);
        }



        [HttpPost("{CartId}/Checkout")]
        public async Task<ActionResult> Checkout(string CartId)
        {

            await _cosmosDbService.DeleteItemAsync(CartId);

            return new OkResult();
        }

        [HttpDelete("{Id}")]
        public async Task<ActionResult> Delete(string Id)
        {
            if (Id == null)
            {
                return BadRequest();
            }

            Cart cart = await _cosmosDbService.GetItemAsync(Id);
            if (cart == null)
            {
                return new NotFoundResult();
            }
            else
            {
                await _cosmosDbService.DeleteItemAsync(Id);
                return new OkResult();
            }
        }


    }
}
