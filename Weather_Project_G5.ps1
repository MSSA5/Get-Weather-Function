function Get-Weather {
   Param(
        [Parameter(Position= 0, Mandatory = $True, HelpMessage="Please provide the City and State", ValueFromPipeline = $True)]$location,
        [Parameter(Position= 1, Mandatory = $True, HelpMessage="How many Days?", ValueFromPipeline =$True)]$days,
        [Parameter(Position= 2, Mandatory = $True, HelpMessage="Please provide the units (C/F)", ValueFromPipeline = $True)]$unit
    )
    Try{
        [decimal]$days | Out-Null
    } Catch {
        Write-Host 'Invalid Days.'
        break
    }
if ($unit -eq 'F' -or $unit -eq 'C') {
    Try {$weatherdata = Invoke-WebRequest -uri "http://api.weatherapi.com/v1/forecast.json?key=039ef7eb236d4cd2a48205504203009&q=$location&days=$days" | ConvertFrom-Json
    } Catch {
        Write-Host 'Invalid Location.'
        break
    }
    $weatherar = New-Object -typename 'object[]' -ArgumentList $weatherdata.forecast.forecastday.date.Count
    $mxt = 'maxtemp_'+$unit
    $mnt = 'mintemp_'+$unit
    Write-Host 'The'$days 'day forecast for' $location 'is'
    for ($i = 0; $i -lt $weatherdata.forecast.forecastday.date.Count; $i++) {
        $weatherar[$i] = [PSCustomObject]@{
            Day = $i+1
            Date = $weatherdata.forecast.forecastday.date[$i]
            Condition = $weatherdata.forecast.forecastday.day.condition.text[$i]
            'Max ' = $weatherdata.forecast.forecastday.day.$mxt[$i]
            'Min ' = $weatherdata.forecast.forecastday.day.$mnt[$i]
            'Chance Rain' = $weatherdata.forecast.forecastday.day.daily_chance_of_rain[$i]+'%'
            'Chance Snow' = $weatherdata.forecast.forecastday.day.daily_chance_of_snow[$i]+'%'
        }        
        switch ($days) {
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
