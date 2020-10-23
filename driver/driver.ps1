$baseUrl = "https://micro-apim.azure-api.net"
$thinkTime = 300
$stopTime = (Get-Date).AddSeconds(300)

$stopTime
while ($stopTime -gt (Get-Date)) {
    Write-Host "Requesting..."
    
        $url = $baseUrl + "/cart/cart"
        $body = @{
            Name='blah'
        }
        $json = $body | ConvertTo-Json
        $cart = Invoke-RestMethod -Method 'Post' -Uri $url -Body $json -ContentType 'application/json'

        Start-Sleep -Milliseconds $thinkTime

        $url = $baseUrl + "/catalog/catalog"
        $catalogItems = Invoke-RestMethod -Method 'Get' -Uri $url

        $numberOfItemsToAdd = Get-Random -Minimum 1 -Maximum 5

        Start-Sleep -Milliseconds $thinkTime

        for($i = 0; $i -lt $numberOfItemsToAdd; $i++)
        {
            $url = $baseUrl + "/cart/cart/" + $cart.id + "/AddItemToCart/" + $catalogItems[$i].Id
            Invoke-RestMethod -Method 'Post' -Uri $url
            Start-Sleep -Milliseconds $thinkTime
        }

        $url = $baseUrl + "/cart/cart/" + $cart.id + "/Checkout"
        Invoke-RestMethod -Uri $url -Method 'Post' -ContentType 'application/json'
    
        Start-Sleep -Milliseconds $thinkTime
}



