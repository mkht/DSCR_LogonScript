Configuration LogonScript
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ScriptPath,

        [Parameter()]
        [ValidateSet('Logon', 'Logoff', 'Startup', 'Shutdown')]
        [string]
        $Type = 'Logon',

        [Parameter()]
        [ValidateRange(0, 99)]
        [int]
        $Index = 0,

        [Parameter()]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [string]
        $Parameters = ''
    )

    # ============================================================
    # Import dependency modules
    # ============================================================
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'DSCR_FileContent'

    # ============================================================
    # Constant variables
    # ============================================================
    $GroupPolicyPath = 'C:\Windows\System32\GroupPolicy'
    $GptIniPath = Join-Path -Path $GroupPolicyPath -ChildPath 'gpt.ini'

    $UserScriptsIniPath = Join-Path -Path $GroupPolicyPath -ChildPath '\User\Scripts\scripts.ini'
    $MachineScriptsIniPath = Join-Path -Path $GroupPolicyPath -ChildPath '\Machine\Scripts\scripts.ini'

    $UserScriptCSE = '{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B66650-4972-11D1-A7CA-0000F87571E3}'
    $MachineScriptCSE = '{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}'

    switch ($Type) {
        'Logon' {
            $TargetScriptsIniPath = $UserScriptsIniPath
            $TargetScriptCSE = $UserScriptCSE
            $TargetExtensionsName = 'gPCUserExtensionNames'
        }
        'Logoff' {
            $TargetScriptsIniPath = $UserScriptsIniPath
            $TargetScriptCSE = $UserScriptCSE
            $TargetExtensionsName = 'gPCUserExtensionNames'
        }
        'Startup' {
            $TargetScriptsIniPath = $MachineScriptsIniPath
            $TargetScriptCSE = $MachineScriptCSE
            $TargetExtensionsName = 'gPCMachineExtensionNames'
        }
        'Shutdown' {
            $TargetScriptsIniPath = $MachineScriptsIniPath
            $TargetScriptCSE = $MachineScriptCSE
            $TargetExtensionsName = 'gPCMachineExtensionNames'
        }
    }

    # ============================================================
    # Rise a warning if the script path does not exist.
    # ============================================================
    Script TestPath {
        SetScript  = {
            $null = $TestScript
        }
        TestScript = {
            $local:ErrorActionPreference = 'Stop'
            if (-not (Test-Path -LiteralPath $using:ScriptPath -PathType Leaf)) {
                Write-Warning ('"{0}" is not exist.' -f $using:ScriptPath)
            }
            return $true
        }
        GetScript  = {
            return @{
                Result = $TestScript
            }
        }
    }

    # ============================================================
    # Increment version numbers in the gpt.ini
    # ============================================================
    Script IncrementGptIniVersion {
        SetScript  = {
            $local:ErrorActionPreference = 'Stop'

            $local:GptIniPath = $using:GptIniPath
            $local:TargetScriptCSE = $using:TargetScriptCSE
            $local:TargetExtensionsName = $using:TargetExtensionsName

            if (-not (Test-Path -LiteralPath $GptIniPath -PathType Leaf)) {
                # Create gpt.ini if not exist.
                ('[General]', "$TargetExtensionsName=[$TargetScriptCSE]", 'Version=65536') |`
                    Out-File -FilePath $GptIniPath -Encoding ascii
            }
            else {
                $GptIniContent = Get-Content -LiteralPath $GptIniPath
                $ExtensionsMatchInfo = $GptIniContent | Select-String -Pattern "$TargetExtensionsName=.*"
                if ($null -eq $ExtensionsMatchInfo) {
                    $GptIniContent += "$TargetExtensionsName=[$TargetScriptCSE]"
                }
                else {
                    $CSEMatchInfo = $GptIniContent | Select-String -Pattern "$TargetExtensionsName=.*\[$TargetScriptCSE\].*"
                    if ($null -eq $CSEMatchInfo) {
                        $private:Index = $ExtensionsMatchInfo.LineNumber - 1
                        $GptIniContent[$private:Index] = [string]($GptIniContent[$private:Index] + "[$TargetScriptCSE]")
                    }
                }

                $VersionMatchInfo = $GptIniContent | Select-String -Pattern 'Version=(.+)'
                if ($VersionMatchInfo.Matches.Groups -and $VersionMatchInfo.Matches.Groups[1].Success) {
                    [int]$CurrentVersionValue = [int]::Parse($VersionMatchInfo.Matches.Groups[1].Value)
                    [int]$NewVersionValue = $CurrentVersionValue + 65536

                    $private:Index = $VersionMatchInfo.LineNumber - 1
                    $GptIniContent[$private:Index] = ('Version={0}' -f $NewVersionValue)
                }

                $GptIniContent | Set-Content -Path $GptIniPath -Encoding ascii -Force
            }
        }
        TestScript = {
            $local:ErrorActionPreference = 'Stop'

            Import-Module -Name DSCR_FileContent -Force -Verbose:$false

            if (-not (Test-Path -LiteralPath $using:GptIniPath -PathType Leaf)) { return $false }
            $ret = Select-String -LiteralPath $using:GptIniPath -Pattern "$using:TargetExtensionsName=.*\[$using:TargetScriptCSE\].*" -Quiet
            if ($false -eq $ret) { return $false }

            if (-not (Test-Path -LiteralPath $using:TargetScriptsIniPath -PathType Leaf)) { return $false }
            $scriptsIni = Get-IniFile -Path $using:TargetScriptsIniPath

            if ($using:Index -ge 1) {
                for ($i = 0; $i -lt $using:Index; $i++) {
                    if ($null -eq $scriptsIni.$using:Type.('{0}CmdLine' -f $i)) {
                        #Get ordinals for number
                        $ordinalIndex = switch ($i % 10) {
                            1 { '{0}st' -f $i }
                            2 { '{0}nd' -f $i }
                            3 { '{0}rd' -f $i }
                            Default { '{0}th' -f $i }
                        }
                        Write-Error ('The {0} entry of the {1} script is not exist. The Value of the Index ({2}) may be invalid.' -f $ordinalIndex, $using:Type, $using:Index)
                    }
                }
            }

            if ($scriptsIni.$using:Type.('{0}CmdLine' -f $using:Index) -ne $using:ScriptPath) { return $false }
            if ($scriptsIni.$using:Type.('{0}Parameters' -f $using:Index) -ne $using:Parameters) { return $false }

            return $true
        }
        GetScript  = {
            return @{
                Result = $TestScript
            }
        }
        DependsOn  = '[Script]TestPath'
    }

    # ============================================================
    # Create a file that defines the logon scripts.
    # ============================================================
    IniFile CmdLine {
        Path      = $TargetScriptsIniPath
        Section   = $Type
        Key       = ('{0}CmdLine' -f $Index)
        Value     = $ScriptPath
        Encoding  = 'unicode'
        DependsOn = '[Script]IncrementGptIniVersion'
    }

    IniFile Parameters {
        Path      = $TargetScriptsIniPath
        Section   = $Type
        Key       = ('{0}Parameters' -f $Index)
        Value     = $Parameters
        Encoding  = 'unicode'
        DependsOn = '[Script]IncrementGptIniVersion'
    }
}
