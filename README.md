# micro
simple sample microservice app

Deploying this sample app currently requires a bit of manual configuration after deployment.

Go to Azure App Config and add values for CosmosDb:Key.
Go to both Azure Web Sites and fill the app setting ConnectionStrings:AppConfig.

Turn on diagnostic settings for AllMetrics and Diagnostic Logging for each resource.

When these objects are available in Bicep, this will not be necessary anymore.

To set up IIS for .NET Core: https://docs.microsoft.com/en-us/aspnet/core/tutorials/publish-to-iis?view=aspnetcore-5.0&tabs=netcore-cli
Install IIS
Download and install hosting bundle 3.1
restart iis
net step was /y
net start w3svc
change thge app pool ProcessModel --> Identity to a user pricipal with access to the wwwroot folder
dotnet publish --configuration Release
copy contents of bin/release/[TARGET FRAMEWORK]/publish to the wwwroot folder on the server (take out the 2 files there)
add appconfig connection string to appconfig.json
restart iis or recycle app pool to use new identity
