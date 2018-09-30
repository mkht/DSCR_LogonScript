@{

    # Script module or binary module file associated with this manifest.
    # RootModule = ''

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = '9ef12355-7e97-4d79-818f-69fc50bccc2a'

    # Author of this module
    Author               = 'mkht'

    # Copyright statement for this module
    Copyright            = '(c) 2018 mkht. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'DSC Resource for managing Logon / Logoff script'

    RequiredModules      = @('DSCR_IniFile')

    FunctionsToExport    = @()

    CmdletsToExport      = @()

    VariablesToExport    = '*'

    AliasesToExport      = @()

    DscResourcesToExport = @('LogonScript')

    PrivateData          = @{
        PSData = @{

            Tags         = ('Logon script', 'DSC', 'DSCResource')

            LicenseUri   = 'https://github.com/mkht/DSCR_LogonScript/blob/master/LICENSE'

            ProjectUri   = 'https://github.com/mkht/DSCR_LogonScript'

            # IconUri = ''

            ReleaseNotes = 'Initial alpha release (not for production use)'
        }
    }
}

