# micro
simple sample microservice app

Deploying this sample app currently requires a bit of manual configuration after deployment.

Go to Azure App Config and add values for CosmosDb:Key.
Go to both Azure Web Sites and fill the app setting ConnectionStrings:AppConfig.

Turn on diagnostic settings for AllMetrics and Diagnostic Logging for each resource.

When these objects are available in Bicep, this will not be necessary anymore.
