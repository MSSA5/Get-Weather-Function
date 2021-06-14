<#
Tasks:
1. API Test Good
2. Variables and Parsing
3. Inputs Good
4. Validation
#>

function Get-Weather($location,$days,$unit) {
   

    
    #$city = Read-Host -Prompt 'What is the City?'
    #$state = Read-Host -Prompt 'What is the State? (Example: CA)'
    #$days = Read-Host -Prompt 'How many days?'
    #$units = Read-Host -Prompt 'What units? (C/F)'



#1. API
    <#
    RAW API Calls:

    http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=47.035534,-122.900827&days=2

    http://www.mapquestapi.com/geocoding/v1/address?key=Yja5atNOmi8Q3XAN1GVjzhBRoIaH158l&location=%22Olympia,WA%22
    #>

#Lat Long Grab Test
#Invoke-WebRequest "http://www.mapquestapi.com/geocoding/v1/address?key=Yja5atNOmi8Q3XAN1GVjzhBRoIaH158l&location=%22Olympia,WA%22"

#Weather Grab Test
#Invoke-WebRequest "http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=47.035534,-122.900827&days=2"


#2. Variables and Parsing

#$city = Read-Host -Prompt 'What is the City?'
#$state = Read-Host -Prompt 'What is the State? (Example: CA)'
#$days = Read-Host -Prompt 'How many days?'
#$units = Read-Host -Prompt 'What units? (C/F)'
#$city='Olympia'
#$state='WA'
#$days="1"
#$units='F'
#Write-Host $city, $state, $days, $units


$georaw = Invoke-WebRequest "http://www.mapquestapi.com/geocoding/v1/address?key=Yja5atNOmi8Q3XAN1GVjzhBRoIaH158l&location=%22$location%2" | ConvertFrom-Json 
$coords= ($georaw.results.locations.latlng.lat[0]).ToString()+','+($georaw.results.locations.latlng.lng[0]).ToString()

#Write-Host $coords



$weatherdata = Invoke-WebRequest "http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=$coords&days=$days" | ConvertFrom-Json

if ($unit -eq 'F'){
Write-Host $weatherdata.forecast.forecastday.date
Write-Host $weatherdata.location.name, $weatherdata.location.region
Write-Host $weatherdata.location.country
Write-Host $weatherdata.forecast.forecastday.day.maxtemp_f
Write-Host $weatherdata.forecast.forecastday.day.mintemp_f
Write-Host $weatherdata.forecast.forecastday.day.avgtemp_f
}
elseif ($unit -eq 'C'){
Write-Host $weatherdata.forecast.forecastday.date
Write-Host $weatherdata.location.name, $weatherdata.location.region
Write-Host $weatherdata.location.country
Write-Host $weatherdata.forecast.forecastday.day.maxtemp_c
Write-Host $weatherdata.forecast.forecastday.day.mintemp_c
Write-Host $weatherdata.forecast.forecastday.day.avgtemp_c
}


<#if($i= 0 ,$i -lt $days, $i++){
$weatherdata.forecastday
}#>
}

