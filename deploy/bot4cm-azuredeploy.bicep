@description('Web app name.')
@minLength(2)
param webAppName string = 'webApp-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The SKU of App Service Plan.')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param sku string = 'B1'

@description('The Runtime stack of current web app')
param linuxFxVersion string = 'PYTHON|3.7'

@description('Git Repo URL')
param repoUrl string = 'https://github.com/benalexkeen/streamlit-azure-app-services.git'

@description('Git Repo branch to deploy')
param repoBranch string = 'main'

var appServicePlanPortalName = 'AppServicePlan-${webAppName}'

resource appServicePlanPortal 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanPortalName
  location: location
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlanPortal.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}

resource webAppName_web 'Microsoft.Web/sites/sourcecontrols@2020-06-01' = {
  parent: webApp
  name: 'web'
  location: location
  properties: {
    repoUrl: repoUrl
    branch: repoBranch
    isManualIntegration: true
  }
}

resource Microsoft_Web_sites_config_webAppName_web 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: webApp
  name: 'web'
  location: location
  properties: {
    appCommandLine: 'python -m streamlit run app/streamlit_app.py --server.port 8000 --server.address 0.0.0.0'
  }
}
