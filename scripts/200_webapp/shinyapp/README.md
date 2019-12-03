# PhenomeXcan Shiny App

1. Become familiar with ShinyApp: https://docs.rstudio.com/shinyapps.io/
1. Execute this in an R shell:
```R
> library(rsconnect)
> # Get the full command below from your session at ShinyApps:
> > rsconnect::setAccountInfo(name='yourLab',
+   token='yourToken',
+   secret='yourSecret')
>
```
1. Before deploying to ShinyApps, you can try the app locally by running:
```R
> shiny::runApp(launch.browser=F)
```
Keep in mind that you need to whitelist your public IP address in Cloud SQL.
1. Deploy the app:
```R
> deployApp(appName='yourAppName')
```
