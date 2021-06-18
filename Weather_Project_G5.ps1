

function Get-Weather {
   Param(
        [Parameter(Position= 0, Mandatory = $True, HelpMessage="Please provide the City and State", ValueFromPipeline = $True)]$location,
        [Parameter(Position= 1, Mandatory = $True, HelpMessage="How many Days?", ValueFromPipeline =$True)]$days,
        [Parameter(Position= 2, Mandatory = $True, HelpMessage="Please provide the units (C/F)", ValueFromPipeline = $True)]$unit
    )
    Try{
        [decimal]$days | Out-Null
    } Catch {
        Write-Host 'Day value entered was not in a valid number format.'
        break
    }
#1. API
#Lat Long Grab Test
#Invoke-WebRequest "http://www.mapquestapi.com/geocoding/v1/address?key=Yja5atNOmi8Q3XAN1GVjzhBRoIaH158l&location=%22Olympia,WA%22"
#Weather Grab Test
#Invoke-WebRequest "http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=47.035534,-122.900827&days=2"

#2. Variables and Parsing
#$location='Olympia, WA'
#$days="5"
#clear-host$unit='F'
#$georaw = Invoke-WebRequest "http://www.mapquestapi.com/geocoding/v1/address?key=Yja5atNOmi8Q3XAN1GVjzhBRoIaH158l&location=%22$location%2" | ConvertFrom-Json 
#$coords= ($georaw.results.locations.latlng.lat[0]).ToString()+','+($georaw.results.locations.latlng.lng[0]).ToString()

$weatherdata = Invoke-WebRequest "http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=$location&days=$days" | ConvertFrom-Json
$weatherar = New-Object -typename 'object[]' -ArgumentList $weatherdata.forecast.forecastday.date.Count
$mxt = 'maxtemp_'+$unit
$mnt = 'mintemp_'+$unit
Write-Host 'The'$days 'day forecast for' $location 'is'
for ($i = 0; $i -lt $weatherdata.forecast.forecastday.date.Count; $i++) {
    $weatherar[$i] = [PSCustomObject]@{
        Day = $i+1
        Date = $weatherdata.forecast.forecastday.date[$i]
        Condition = $weatherdata.forecast.forecastday.day.condition.text[$i]
        'Max Temp' = $weatherdata.forecast.forecastday.day.$mxt[$i]
        'Min Temp' = $weatherdata.forecast.forecastday.day.$mnt[$i]
        'Chance of Rain' = $weatherdata.forecast.forecastday.day.daily_chance_of_rain[$i]+'%'
        'Chance of Snow' = $weatherdata.forecast.forecastday.day.daily_chance_of_snow[$i]+'%'
    }   
    switch ($days) {
        1 { 
            $weatherar[0].date = $weatherdata.forecast.forecastday.date
            $weatherar[0].condition = $weatherdata.forecast.forecastday.day.condition.text
         }
}
}
$weatherar | Format-Table
#$weatherar | Format-List
#$weatherar | Out-Gridview


<#
Write-Host -nonewline $weatherdata.location.name ', ' $weatherdata.location.region ', '
Write-Host $weatherdata.location.country
switch ($unit) {
    'F' { 
        Write-Host $weatherdata.location


     }
    'C' { 



    }
    Default {

    }
}
if ($unit -eq 'F'){

Write-Host $weatherdata.forecast.forecastday.date
Write-Host $weatherdata.forecast.forecastday.day.maxtemp_f
Write-Host $weatherdata.forecast.forecastday.day.mintemp_f
Write-Host $weatherdata.forecast.forecastday.day.avgtemp_f
}
elseif ($unit -eq 'C'){
Write-Host $weatherdata.forecast.forecastday.date
Write-Host $weatherdata.forecast.forecastday.day.maxtemp_c
Write-Host $weatherdata.forecast.forecastday.day.mintemp_c
Write-Host $weatherdata.forecast.forecastday.day.avgtemp_c
}

#>
<#if($i= 0 ,$i -lt $days, $i++){
$weatherdata.forecastday
}#>
}

