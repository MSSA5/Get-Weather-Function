function Get-Weather {
    <# .SYNOPSIS #>
    Param(
         [Parameter(Position= 0, ValueFromPipeline = $True)]$location = $(Read-Host -prompt "Please provide the City, State") #The City and State. Format: City, ST
         ,[Parameter(Position= 1, ValueFromPipeline =$True)]$days = $(Read-Host -prompt "Please provide the Forecast Length (Max 3 Days)") #Whole Numbered Forecast Length.
         ,[Parameter(Position= 2, ValueFromPipeline = $True)]$unit = $(Read-Host -prompt "Please provide the Units (C/F)") #Temperature Units. Valid inputs are F for fahrenheit or C for celcius.
     )
 if ($unit -eq 'F' -or $unit -eq 'C') {
    Try{
        $days = [byte]$days
    } Catch {
        Write-Host 'Invalid Days.'
        Get-Error -Newest 1 | Write-Host
        Break
    }
    Try {
        $city,$state = $location.split(',')
        $georaw = Invoke-WebRequest "http://www.mapquestapi.com/geocoding/v1/address?key=Yja5atNOmi8Q3XAN1GVjzhBRoIaH158l&city=$city&state=$state" | ConvertFrom-Json
        $coords = $georaw.results.locations.latlng.lat[0].toString() +','+ $georaw.results.locations.latlng.lng[0].ToString()
        if ($days -gt 3) {
            Write-Host 'Maximum Forecast Length is 3 Days. Attempting 3 Day Forecast.'
            $days = 3
        }
        if ($days -eq 0) {
            Write-Host 'Minimum Forecast Length is 1 Day. Attempting 1 Day Forecast.'
            $days = 1
        }
        $weatherdata = Invoke-WebRequest "http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=$coords&days=$days" | ConvertFrom-Json
    } Catch {
        Write-Host 'Invalid Location.'
        Get-Error -Newest 1 | Write-Host
        Break
    }
    [byte]$c = $weatherdata.forecast.forecastday.date.Count
    if ($city -ne $weatherdata.location.name) {
        Write-Host 'EXACT LOCATION WAS NOT FOUND.' 
        Write-Host $c 'FORECAST FOR NEAREST MATCH,' $weatherdata.location.name.toUpper() $weatherdata.location.region.toUpper()
    }
    else {
    Write-Host $weatherdata.location.name.toUpper() $weatherdata.location.region.toUpper() $c 'DAY FORECAST'
    }
    $weatherar = New-Object -typename 'object[]' -ArgumentList $c
    $mxt = 'maxtemp_'+$unit
    $mnt = 'mintemp_'+$unit
    for ($i = 0; $i -lt $c; $i++) {
        $weatherar[$i] = [PSCustomObject]@{
            Date = $weatherdata.forecast.forecastday.date[$i] | Get-Date -Format d
            'Weather Conditions' = (Get-Culture).TextInfo.ToTitleCase($weatherdata.forecast.forecastday.day.condition.text[$i])
            'Max Temp' = ("{0:###.0}" -f [decimal]$weatherdata.forecast.forecastday.day.$mxt[$i]).ToString()+'??'+$unit.toUpper()
            'Min Temp' = ("{0:###.0}" -f [decimal]$weatherdata.forecast.forecastday.day.$mnt[$i]).ToString()+'??'+$unit.toUpper()
            'UV Index' = [int]$weatherdata.forecast.forecastday.day.uv[$i] 
            'Chance Rain' = $weatherdata.forecast.forecastday.day.daily_chance_of_rain[$i].toString()+'%'
            'Chance Snow' = $weatherdata.forecast.forecastday.day.daily_chance_of_snow[$i].toString()+'%'
            'Sun Rise' = $weatherdata.forecast.forecastday.astro.sunrise[$i] | Get-date -Format t
            'Sun Set' = $weatherdata.forecast.forecastday.astro.sunset[$i] | Get-date -Format t
            'Moon Phase' = $weatherdata.Forecast.forecastday.astro.moon_phase[$i]
        }        
    switch ($c) {
        1 { 
            $weatherar[0].date = $weatherdata.forecast.forecastday.date | Get-Date -Format d
            $weatherar[0].'Weather Conditions' = (Get-Culture).TextInfo.ToTitleCase($weatherdata.forecast.forecastday.day.condition.text)
            $weatherar[0].'Sun Rise' = $weatherdata.forecast.forecastday.astro.sunrise | Get-date -Format t
            $weatherar[0].'Sun Set' = $weatherdata.Forecast.forecastday.astro.sunset | Get-date -Format t
            $weatherar[0].'Moon Phase' = $weatherdata.Forecast.forecastday.astro.moon_phase
            }
        } 
    }
    $weatherar 
}
else{
    Write-Host 'Invalid Units.
Valid inputs are either'F' for fahrenheit or 'C' for celcius.'
    break
    }
}
