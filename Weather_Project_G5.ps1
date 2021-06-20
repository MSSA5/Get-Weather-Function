function Get-Weather {
    Param(
         [Parameter(Position= 0, Mandatory = $True, HelpMessage="Please provide the City and State", ValueFromPipeline = $True)]$location,
         [Parameter(Position= 1, Mandatory = $True, HelpMessage="Forecast Length? (Max 3 Days)", ValueFromPipeline =$True)]$days,
         [Parameter(Position= 2, Mandatory = $True, HelpMessage="Please provide the units (C/F)", ValueFromPipeline = $True)]$unit
     )
     Try{
         [int]$days | Out-Null
         if ($days -gt 3) {
            $days = 3
            Write-Host 'Max Forecast Length is 3 days. Attempting 3 day forecast.'
         }
     } Catch {
         Write-Host 'Invalid Days.'
         break
     }
 if ($unit -eq 'F' -or $unit -eq 'C') {
     Try {$weatherdata = Invoke-WebRequest "http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=$location&days=$days" | ConvertFrom-Json
     } Catch {
         Write-Host 'Invalid Location.'
         break
     }
     [int]$c = $weatherdata.forecast.forecastday.date.Count
     Write-Host $weatherdata.location.name.toUpper() $weatherdata.location.region.toUpper() $c 'DAY FORECAST'
     $weatherar = New-Object -typename 'object[]' -ArgumentList $c
     $mxt = 'maxtemp_'+$unit
     $mnt = 'mintemp_'+$unit
     for ($i = 0; $i -lt $c; $i++) {
         $weatherar[$i] = [PSCustomObject]@{
             Day = $i+1
             Date = $weatherdata.forecast.forecastday.date[$i] | Get-Date -Format d
             'Weather Conditions' = (Get-Culture).TextInfo.ToTitleCase($weatherdata.forecast.forecastday.day.condition.text[$i])
             'Max Temp' = ("{0:###.0}" -f [decimal]$weatherdata.forecast.forecastday.day.$mxt[$i]).ToString()+'°'+$unit.toUpper()
             'Min Temp' = ("{0:###.0}" -f [decimal]$weatherdata.forecast.forecastday.day.$mnt[$i]).ToString()+'°'+$unit.toUpper()
             'Chance of Rain' = $weatherdata.forecast.forecastday.day.daily_chance_of_rain[$i].toString()+'%' 
             'Chance of Snow' = $weatherdata.forecast.forecastday.day.daily_chance_of_snow[$i].toString()+'%'
             'Sun Rise' = $weatherdata.forecast.forecastday.astro.sunrise[$i] | Get-date -Format t
             'Sun Set' = $weatherdata.forecast.forecastday.astro.sunset[$i] | Get-date -Format t
             'Moon Phase' = $weatherdata.Forecast.forecastday.astro.moon_phase[$i]
         }        
         switch ($c) {
             1 { 
                 $weatherar[0].date = $weatherdata.forecast.forecastday.date
                 $weatherar[0].condition = $weatherdata.forecast.forecastday.day.condition.text
             }
         } 
     }
     $weatherar
 }
 else{
     Write-Host 'Invalid Units.'
     break
     }
 }
