using System.Collections.Generic;
using Newtonsoft.Json;

namespace cart.Models
{
    public class Cart
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }

        [JsonProperty(PropertyName = "name")]
        public string Name { get; set; }

        public List<CatalogItem> Items { get; set; }

        public Cart()
        {
            this.Items = new List<CatalogItem>();
        }
    }
}