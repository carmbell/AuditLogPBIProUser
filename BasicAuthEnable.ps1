$WinRMClient = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
$Name = "AllowBasic"
$value = "1"
IF (!(Test-Path $WinRMClient)) {
   New-Item -Path $WinRMClient -Force | Out-Null
   New-ItemProperty -Path $WinRMClient -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
} ELSE {
   New-ItemProperty -Path $WinRMClient -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}
