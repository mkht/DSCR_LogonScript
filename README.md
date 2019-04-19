DSCR_LogonScript
====

DSC Resource for set Logon / Logoff / Startup / Shutdown script in the local group policy

----
## Installation
You can install this module from [PowerShell Gallery](https://www.powershellgallery.com/packages/DSCR_LogonScript/).
```Powershell
Install-Module -Name DSCR_LogonScript
```

## Dependencies
* [DSCR_FileContent](https://github.com/mkht/DSCR_FileContent)

----
## **LogonScript**
Set Logon / Logoff / Startup / Shutdown script in the local group policy

### Properties
+ [string] **ScriptPath** (Require):
    + The path of the script.

+ [string] **Parameters** (Optional):
    + The parameter of the script.

+ [string] **ScriptType** (Optional):
    + Specify the script type is `Command` or `PowerShell` (The default is `Command`)

+ [string] **RunAt** (Optional):
    + Specify when the script should be execute.
    + The default is `Logon`. (`Logon` / `Logoff` / `Startup` / `Shutdown`)

+ [int] **Index** (Optional):
    + The order of the script should be execute.
    + The default is `0`. (`0 - 99`)


### Examples
+ **Example 1**: Set logon scripts
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_LogonScript
    LogonScript logon1
    {
        RunAt = 'Logon'
        ScriptPath = 'C:\first.bat'
        Index = 0
    }
    
    LogonScript logon2
    {
        RunAt = 'Logon'
        ScriptPath = 'C:\second.bat'
        Parameters = 'param x'
        Index = 1
    }
}
```

+ **Example 2**: Set a logon PowerShell script
```Powershell
Configuration Example2
{
    Import-DscResource -ModuleName DSCR_LogonScript
    LogonScript logonPS1
    {
        RunAt = 'Logon'
        ScriptPath = 'C:\PSFirst.ps1'
        ScriptType = 'PowerShell'
        Index = 0
    }
}
```

+ **Example 3**: Set logon / logoff / startup / shutdown scripts
```Powershell
Configuration Example3
{
    Import-DscResource -ModuleName DSCR_LogonScript
    LogonScript logon
    {
        RunAt = 'Logon'
        ScriptPath = 'C:\logon.bat'
    }
    
    LogonScript logoff
    {
        RunAt = 'Logoff'
        ScriptPath = 'C:\logoff.bat'
    }
    
    LogonScript startup
    {
        RunAt = 'Startup'
        ScriptPath = 'C:\startup.bat'
    }
    
    LogonScript shutdown
    {
        RunAt = 'Shutdown'
        ScriptPath = 'C:\shutdown.bat'
    }
}
```

----
## ChangeLog
### Unreleased
 + Add an new property `ScriptType`
 + **[BREAKING]** Change the param name from `Type` to `RunAt`
 + Change the dependencies module from [DSCR_IniFile](https://github.com/mkht/DSCR_IniFile) to [DSCR_FileContent](https://github.com/mkht/DSCR_FileContent)
 + miscellaneous fixes.

### 0.0.2
 + Initial public release
