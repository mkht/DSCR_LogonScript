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
* [DSCR_IniFile](https://github.com/mkht/DSCR_IniFile)

----
## **LogonScript**
Set Logon / Logoff / Startup / Shutdown script in the local group policy

### Properties
+ [string] **ScriptPath** (Require):
    + The path of the script.

+ [string] **Parameters** (Optional):
    + The parameter of the script.

+ [string] **Type** (Optional):
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
        Type = 'Logon'
        ScriptPath = 'C:\first.bat'
        Index = 0
    }
    
    LogonScript logon2
    {
        Type = 'Logon'
        ScriptPath = 'C:\second.bat'
        Parameters = 'param x'
        Index = 1
    }
}
```

+ **Example 2**: Set logon / logoff / startup / shutdown scripts
```Powershell
Configuration Example2
{
    Import-DscResource -ModuleName DSCR_LogonScript
    LogonScript logon
    {
        Type = 'Logon'
        ScriptPath = 'C:\logon.bat'
    }
    
    LogonScript logoff
    {
        Type = 'Logoff'
        ScriptPath = 'C:\logoff.bat'
    }
    
    LogonScript startup
    {
        Type = 'Startup'
        ScriptPath = 'C:\startup.bat'
    }
    
    LogonScript shutdown
    {
        Type = 'Shutdown'
        ScriptPath = 'C:\shutdown.bat'
    }
}
```

----
## ChangeLog
### 0.0.2
 + Initial public release
