function Get-Uptime(){
    $wmi = Get-WmiObject -Class Win32_OperatingSystem
    $currentTime = $wmi.ConvertToDateTime($wmi.LocalDateTime)
    $lastBoot = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
    $uptime = $currentTime - $lastBoot
    return $uptime
}