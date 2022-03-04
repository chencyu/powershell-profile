function Get-Temperature
{
    $t = Get-CimInstance MSAcpi_ThermalZoneTemperature -Namespace "root/wmi"
    $returnTemper = @()
    foreach ($temper in $t.CurrentTemperature)
    {
        $TemperKelvin = $temper / 10
        $TemperCelcius = $TemperKelvin - 273.15
        $TemperFahrenheit = $TemperCelcius * 1.8 + 32
        $returnTemper += $TemperCelcius.ToString() + "°C"
    }
    return $returnTemper
}
