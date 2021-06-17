#John Sotelo, Seidu Idrisu, Ryan Richter, Logan Pare#       #WeatherApiGroup5#

function Get-Weather
{
    Param(
        [Parameter(Position= 0, Mandatory = $True, HelpMessage="Provide City, State", ValueFromPipeline = $True)]

        $location,

        [Parameter(Position= 1, Mandatory = $True, HelpMessage="Provide Number of Days", ValueFromPipeline =$True)]

        $numberdays,

        [Parameter(Position= 2, Mandatory= $True, HelpMessage="Provide Unit (C or F)", ValueFromPipeline = $True)]

        $Unit
        
    )

$URI = "http://api.weatherapi.com/v1/forecast.json?key=a5a6add916c84037bc635738211506&q=$location&days-$numberdays"

$response = Invoke-RestMethod -Uri $URL -Method Get -ResponseHeadersVariable r -StatusCodeVariable s
    if ($s -eq 200) {
    }
    else {
    $r
    }
    $fahrenheit = $response.current.temp_F
    $celsius = $response.current.temp_C
    $date = Get-Date -DisplayHint Date
    "Today is $date , the weather in $location is $fahrenheit F and $celsius C"
} #End Function Get-Weather