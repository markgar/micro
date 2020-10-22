
$stopTime = (Get-Date).AddSeconds(300)

$stopTime
while ($stopTime -gt (Get-Date)) {
    Write-Host "Requesting..."
    
        $url = "https://micro-cart.azurewebsites.net/cart"
        $body = @{
            Name='blah'
        }
        $json = $body | ConvertTo-Json
        $cart = Invoke-RestMethod -Method 'Post' -Uri $url -Body $json -ContentType 'application/json'

        Start-Sleep -Milliseconds 600

        $url = "https://micro-catalog.azurewebsites.net/catalog"
        $catalogItems = Invoke-RestMethod -Method 'Get' -Uri $url

        $numberOfItemsToAdd = Get-Random -Minimum 1 -Maximum 5

        Start-Sleep -Milliseconds 600

        for($i = 0; $i -lt $numberOfItemsToAdd; $i++)
        {
            $url = "https://micro-cart.azurewebsites.net/cart/" + $cart.id + "/AddItemToCart/" + $catalogItems[$i].Id
            Invoke-RestMethod -Method 'Post' -Uri $url
            Start-Sleep -Milliseconds 600
        }

        $url = "https://micro-cart.azurewebsites.net/cart/" + $cart.id + "/Checkout"
        Invoke-RestMethod -Uri $url -Method 'Post' -ContentType 'application/json'
    
        Start-Sleep -Milliseconds 600
}



