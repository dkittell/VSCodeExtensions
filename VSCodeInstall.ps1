<#
 Prerequisites:
    Windows:
        1. Chocolatey - https://chocolatey.org/install
            Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        2. PowerShell 6 Core
            choco install powershell-core -y
    Mac OSX:
        1. HomeBrew - https://brew.sh/
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        2. PowerShell 6 Core
            brew cask install powershell
    Ubuntu:
        1. PowerShell 6 Code - visit https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6 for specific instructions
    Raspberry Pi:
        1. PowerShell 6 Core - Experimental Intall - visit https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6
#>

Clear-Host
Write-Output "This script will install Visual Studio Code along with the following extensions."
Write-Output "     HookyQR.beautify - This extension will help make JavaScript code look better."
Write-Output "     dbaeumer.jshint & dbaeumer.vscode-eslint - These extensions assist in writing proper code."
Write-Output "     eamodio.gitlens - This extension helps with viewing changes in a Git Repo"
Write-Output "     ms-vscode.vs-keybindings - This extension will add helpful keyboard shortcuts"
Write-Output " "

# Windows Functions - Start
function Choco-Installed ($program) {
    $result = $(choco list -lo | Where-Object { $_.ToLower().StartsWith($program.ToLower()) })

    if ($result) {
        Write-Output "$result Installed"
    }
    else {
        Write-Output "Installing $result"
        choco install $program -y
    }
}
function Get-FileDownload ([string]$WebURL, [string]$FullFilePath) {
    # Give a basic message to the user to let them know what we are doing
    Write-Output "Downloading '$WebURL' to '$FullFilePath'"

    $uri = New-Object "System.Uri" "$WebURL"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(30000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength() / 1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $FullFilePath, Create
    $buffer = New-Object byte[] 10KB
    $count = $responseStream.Read($buffer, 0, $buffer.length)
    $downloadedBytes = $count
    while ($count -gt 0) {
        [System.Console]::Write("`r`nDownloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes / 1024), $totalLength)
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer, 0, $buffer.length)
        $downloadedBytes = $downloadedBytes + $count
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()

    # Give a basic message to the user to let them know we are done
    Write-Output "`r`nDownload complete"
}

function AddSystemPaths ([array]$PathsToAdd) {
    #http://blogs.technet.com/b/sqlthoughts/archive/2008/12/12/powershell-function-to-add-system-path.aspx


    $VerifiedPathsToAdd = ""

    foreach ($Path in $PathsToAdd) {
        if ($Env:Path -like "*$Path*") {
            Write-Output "  Path to $Path already added"
        }
        else {
            $VerifiedPathsToAdd += ";$Path"; Write-Output "  Path to $Path needs to be added"
        }
    }

    if ($VerifiedPathsToAdd -ne "") {
        Write-Output "Adding paths: $VerifiedPathsToAdd"
        [System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + "$VerifiedPathsToAdd", "Machine")
        Write-Output "Note: The new path does NOT take immediately in running processes. Only new processes will see new path."
    }
}
# Windows Functions - Stop

# Determine OS
if ($IsLinux) {
    Write-Output "Linux"
    if ($(lsb_release -is) -eq 'Raspbian') {
        Write-Output "Raspbian (Raspberry Pi is experimental)"
        Pause
        wget https://packagecloud.io/headmelted/codebuilds/gpgkey -O - | sudo apt-key add -
        curl -L https://code.headmelted.com/installers/apt.sh | sudo bash
        code-oss --install-extension HookyQR.beautify
        code-oss --install-extension dbaeumer.jshint
        code-oss --install-extension dbaeumer.vscode-eslint
        code-oss --install-extension eamodio.gitlens
        code-oss --install-extension ms-vscode.vs-keybindings
    }
    elseif ($(lsb_release -is) -eq 'Ubuntu') {
        sudo apt update
        sudo apt install -y software-properties-common apt-transport-https wget
        wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
        sudo apt update
        sudo apt install code -y

        code --install-extension HookyQR.beautify
        code --install-extension dbaeumer.jshint
        code --install-extension dbaeumer.vscode-eslint
        code --install-extension eamodio.gitlens
        code --install-extension ms-vscode.vs-keybindings
    }
    else {
        Write-Output "Sorry currently not supported"
    }
}
elseif ($IsMacOS) {
    # Write-Output "macOS"
    brew cask install visual-studio-code
    code --install-extension HookyQR.beautify
    code --install-extension dbaeumer.jshint
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension eamodio.gitlens
    code --install-extension ms-vscode.vs-keybindings
}
elseif ($IsWindows) {
    Write-Output "Windows"

    Choco-Installed vscode


    AddSystemPaths ("C:\Program Files\Microsoft VS Code")

    $CurrentDir = $((Get-Item -Path ".\").FullName)

    & code --install-extension HookyQR.beautify
    & code --install-extension dbaeumer.jshint
    & code --install-extension dbaeumer.vscode-eslint
    & code --install-extension eamodio.gitlens
    & code --install-extension ms-vscode.vs-keybindings

}
