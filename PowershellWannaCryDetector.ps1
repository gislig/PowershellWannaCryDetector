#CREATED BY GISLI GUDMUNDSSON

#GLOBAL VARIABLES

$MailTo = "admin@yourcompany.com"
$SmptServer = "yourmxserver.domain.com"


function SendInfectionMessage(){
    Send-MailMessage -To $MailTo -From "$env:COMPUTERNAME" -Subject "WannaCry Infection Detected - $env:COMPUTERNAME" -Body "WannaCry Infection Was Likely Detected on Computer $env:COMPUTERNAME. Please contact Username $env:USERNAME to investigate further. The Network Was Disabled On Remote Machine" -SmtpServer $SmtpServer
}

function DisableInfectedComputer(){
    #Send The message to IT Admin
    SendInfectionMessage

    #Search for all network working network adapters
    $NetworkAdapters = get-wmiobject win32_networkadapter | where { $_.MACAddress -ne $null }
    foreach($NetworkAdapter in $NetworkAdapters){
        #Disables Network Adapters
        $NetworkAdapter.Disable()
    }
}

function MainDetection(){
    #Figures out if the temp storage has specified extension
    $TempFilePath = $env:TEMP 
    $FilesInTemp = Get-ChildItem -Path $TempFilePath -Filter "*.WCRYT" -Recurse
    
    #Checks for if the computer has already been affected
    $Desktop = $env:USERPROFILE + "\Desktop"
    $GetWallpaper = Get-ChildItem -Path $Desktop -Filter "!WannaCryptor!.bmp" -Recurse

    #If it contains any files then run the DisableInfectedComputer
    if($FilesInTemp -ne $null -or $GetWallpaper -ne $null){
        DisableInfectedComputer
    }
}

#Run detection program
MainDetection