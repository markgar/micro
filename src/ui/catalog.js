  
function AppViewModel() {

    var self = this;
    self.catalogItems = ko.observableArray([]);

    this.getCatalogItems = function () {
        $.getJSON("https://micro-catalog-web-2tg.azurewebsites.net/catalog", function(data) { 
    
            var items = data.map(ConvertToCatalogItem);
            self.catalogItems(items)
        })
    };

    function ConvertToCatalogItem(item) {

        var catalogItem = {};
        catalogItem.id = item.id;
        catalogItem.name = item.name;
        catalogItem.description = item.description;
        catalogItem.price = item.price;

        return catalogItem;
    }
}

// Activates knockout.js
var vm = new AppViewModel();
ko.applyBindings(vm);
vm.getCatalogItems();