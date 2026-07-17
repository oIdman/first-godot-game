param(
    [string]$NewVersion,
    [int]$CountdownSeconds = 10
)

$msg = "Game version {0} is ready. No server restart needed for a client-side game." -f $NewVersion
Write-Output $msg
