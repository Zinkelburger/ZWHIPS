# Get the full path of the image
$imagePath = Join-Path -Path (Get-Location) -ChildPath "firefoxes.png"

# Load necessary functions
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Define constants
$SPI_SETDESKWALLPAPER = 0x0014
$UPDATE_INI_FILE = 0x01
$SEND_CHANGE = 0x02

# Set the wallpaper for the current user
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $imagePath, $UPDATE_INI_FILE -bor $SEND_CHANGE)

# To set the wallpaper for all users, you would need to set it in the registry
# This requires administrative privileges
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name Wallpaper -Value $imagePath
