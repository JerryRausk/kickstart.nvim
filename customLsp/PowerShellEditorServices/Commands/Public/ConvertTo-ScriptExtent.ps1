# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function ConvertTo-ScriptExtent {
    <#
    .EXTERNALHELP ..\PowerShellEditorServices.Commands-help.xml
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Language.IScriptExtent])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByOffset')]
        [Alias('StartOffset', 'Offset')]
        [int] $StartOffsetNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByOffset')]
        [Alias('EndOffset')]
        [int] $EndOffsetNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByPosition')]
        [Alias('StartLine', 'Line')]
        [int] $StartLineNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByPosition')]
        [Alias('StartColumn', 'Column')]
        [int] $StartColumnNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByPosition')]
        [Alias('EndLine')]
        [int] $EndLineNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByPosition')]
        [Alias('EndColumn')]
        [int] $EndColumnNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByPosition')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByOffset')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByBuffer')]
        [Alias('File', 'FileName')]
        [string] $FilePath = $psEditor.GetEditorContext().CurrentFile.Path,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByBuffer')]
        [Alias('Start')]
        [Microsoft.PowerShell.EditorServices.Extensions.IFilePosition, Microsoft.PowerShell.EditorServices] $StartBuffer,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByBuffer')]
        [Alias('End')]
        [Microsoft.PowerShell.EditorServices.Extensions.IFilePosition, Microsoft.PowerShell.EditorServices] $EndBuffer,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByExtent')]
        [System.Management.Automation.Language.IScriptExtent] $Extent
    )
    begin {
        $fileContext = $psEditor.GetEditorContext().CurrentFile
        $emptyExtent = [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::Empty
    }
    process {
        # Already a InternalScriptExtent, FileScriptExtent or is empty.
        $returnAsIs = $Extent -and
            ($Extent.StartOffset -or $Extent.EndOffset -or $Extent -eq $emptyExtent)

        if ($returnAsIs) {
            return $Extent
        }

        if ($StartOffsetNumber) {
            $startOffset = $StartOffsetNumber
            $endOffset = $EndOffsetNumber

            # Allow creating a single position extent with just the offset parameter.
            if (-not $EndOffsetNumber) {
                $endOffset = $startOffset
            }

            return [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::FromOffsets(
                $fileContext,
                $startOffset,
                $endOffset)
        }

        if ($StartBuffer) {
            if (-not $EndBuffer) {
                $EndBuffer = $StartBuffer
            }

            return [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::FromPositions(
                $fileContext,
                $StartBuffer.Line,
                $StartBuffer.Column,
                $EndBuffer.Line,
                $EndBuffer.Column)
        }

        # Allow piping a single line and column to get a zero length script extent.
        if ($PSBoundParameters.ContainsKey('StartColumnNumber') -and -not $PSBoundParameters.ContainsKey('EndColumnNumber')) {
            $EndColumnNumber = $StartColumnNumber
        }

        if ($PSBoundParameters.ContainsKey('StartLineNumber') -and -not $PSBoundParameters.ContainsKey('EndLineNumber')) {
            $EndLineNumber = $StartLineNumber
        }

        # Protect against zero as a value since lines and columns start at 1
        if (-not $StartColumnNumber) {
            $StartColumnNumber = 1
        }

        if (-not $StartLineNumber) {
            $StartLineNumber = 1
        }

        if (-not $EndLineNumber) {
            $EndLineNumber = 1
        }

        if (-not $EndColumnNumber) {
            $EndColumnNumber = 1
        }

        return [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::FromPositions(
            $fileContext,
            $StartLineNumber,
            $StartColumnNumber,
            $EndLineNumber,
            $EndColumnNumber)
    }
}

# SIG # Begin signature block
# MIIoRQYJKoZIhvcNAQcCoIIoNjCCKDICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCArNi6HQ5eMUAz9
# cXhU8YSv7SRI9434IV7YYDMjrPkUZaCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
# Bv9XKydyAAAAAAQEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTE0WhcNMjUwOTExMjAxMTE0WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC0KDfaY50MDqsEGdlIzDHBd6CqIMRQWW9Af1LHDDTuFjfDsvna0nEuDSYJmNyz
# NB10jpbg0lhvkT1AzfX2TLITSXwS8D+mBzGCWMM/wTpciWBV/pbjSazbzoKvRrNo
# DV/u9omOM2Eawyo5JJJdNkM2d8qzkQ0bRuRd4HarmGunSouyb9NY7egWN5E5lUc3
# a2AROzAdHdYpObpCOdeAY2P5XqtJkk79aROpzw16wCjdSn8qMzCBzR7rvH2WVkvF
# HLIxZQET1yhPb6lRmpgBQNnzidHV2Ocxjc8wNiIDzgbDkmlx54QPfw7RwQi8p1fy
# 4byhBrTjv568x8NGv3gwb0RbAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU8huhNbETDU+ZWllL4DNMPCijEU4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMjkyMzAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIjmD9IpQVvfB1QehvpC
# Ge7QeTQkKQ7j3bmDMjwSqFL4ri6ae9IFTdpywn5smmtSIyKYDn3/nHtaEn0X1NBj
# L5oP0BjAy1sqxD+uy35B+V8wv5GrxhMDJP8l2QjLtH/UglSTIhLqyt8bUAqVfyfp
# h4COMRvwwjTvChtCnUXXACuCXYHWalOoc0OU2oGN+mPJIJJxaNQc1sjBsMbGIWv3
# cmgSHkCEmrMv7yaidpePt6V+yPMik+eXw3IfZ5eNOiNgL1rZzgSJfTnvUqiaEQ0X
# dG1HbkDv9fv6CTq6m4Ty3IzLiwGSXYxRIXTxT4TYs5VxHy2uFjFXWVSL0J2ARTYL
# E4Oyl1wXDF1PX4bxg1yDMfKPHcE1Ijic5lx1KdK1SkaEJdto4hd++05J9Bf9TAmi
# u6EK6C9Oe5vRadroJCK26uCUI4zIjL/qG7mswW+qT0CW0gnR9JHkXCWNbo8ccMk1
# sJatmRoSAifbgzaYbUz8+lv+IXy5GFuAmLnNbGjacB3IMGpa+lbFgih57/fIhamq
# 5VhxgaEmn/UjWyr+cPiAFWuTVIpfsOjbEAww75wURNM1Imp9NJKye1O24EspEHmb
# DmqCUcq7NqkOKIG4PVm3hDDED/WQpzJDkvu4FrIbvyTGVU01vKsg4UfcdiZ0fQ+/
# V0hf8yrtq9CkB8iIuk5bBxuPMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGiUwghohAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIPdDfua2HoHSC+WsA9Kd4vwx
# /69pMrly3wNqXl3Q9Zb6MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAXDfJsDat31+UiqlTP2f4hnsyE9WGNS1Q1kBxMCGwUWKHNlAery3LchE3
# G0voyrFvDJR/ikI/tkV+7uQGw9GDTXbBsNeVNJ8ZujL5nqYNSWeDtij/bjaMiipR
# x3xBY0NAwJrc/yqidHYGhz4YHxgf5+v1p935ShXKmMuGx2PvlloBgsMg59UsHjWq
# e65dj03spyObRFoJrt8nkGceZevxyqWefxZGL6UKckaE5vh00v53mZ1MIoVFHxlv
# 9tv+0JRbpdQemKN+8S6SPcTaGVr73EvcSB/ouAzyZiP6afukpvDBDNDeTFzWK/qO
# Z6vIH7t9VpdNBO33U1U4pnGvJPNWraGCF68wgherBgorBgEEAYI3AwMBMYIXmzCC
# F5cGCSqGSIb3DQEHAqCCF4gwgheEAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFaBgsq
# hkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCA1c5RiRsOGHal5lAKvjIykc08WybXkQvUyGhh7u65qMgIGZ0oHIO53
# GBMyMDI0MTIwNDIzNDA0Mi41NTVaMASAAgH0oIHZpIHWMIHTMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# Tjo0MDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaCCEf0wggcoMIIFEKADAgECAhMzAAAB/tCowns0IQsBAAEAAAH+MA0G
# CSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTI0
# MDcyNTE4MzExOFoXDTI1MTAyMjE4MzExOFowgdMxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9w
# ZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjQwMUEt
# MDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvLwhFxWlqA43olsE4PCe
# gZ4mSfsH2YTSKEYv8Gn3362Bmaycdf5T3tQxpP3NWm62YHUieIQXw+0u4qlay4AN
# 3IonI+47Npi9fo52xdAXMX0pGrc0eqW8RWN3bfzXPKv07O18i2HjDyLuywYyKA9F
# mWbePjahf9Mwd8QgygkPtwDrVQGLyOkyM3VTiHKqhGu9BCGVRdHW9lmPMrrUlPWi
# YV9LVCB5VYd+AEUtdfqAdqlzVxA53EgxSqhp6JbfEKnTdcfP6T8Mir0HrwTTtV2h
# 2yDBtjXbQIaqycKOb633GfRkn216LODBg37P/xwhodXT81ZC2aHN7exEDmmbiWss
# jGvFJkli2g6dt01eShOiGmhbonr0qXXcBeqNb6QoF8jX/uDVtY9pvL4j8aEWS49h
# KUH0mzsCucIrwUS+x8MuT0uf7VXCFNFbiCUNRTofxJ3B454eGJhL0fwUTRbgyCbp
# LgKMKDiCRub65DhaeDvUAAJT93KSCoeFCoklPavbgQyahGZDL/vWAVjX5b8Jzhly
# 9gGCdK/qi6i+cxZ0S8x6B2yjPbZfdBVfH/NBp/1Ln7xbeOETAOn7OT9D3UGt0q+K
# iWgY42HnLjyhl1bAu5HfgryAO3DCaIdV2tjvkJay2qOnF7Dgj8a60KQT9QgfJfwX
# nr3ZKibYMjaUbCNIDnxz2ykCAwEAAaOCAUkwggFFMB0GA1UdDgQWBBRvznuJ9SU2
# g5l/5/b+5CBibbHF3TAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBf
# BgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmww
# bAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0El
# MjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUF
# BwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEAiT4NUvO2lw+0
# dDMtsBuxmX2o3lVQqnQkuITAGIGCgI+sl7ZqZOTDd8LqxsH4GWCPTztc3tr8AgBv
# sYIzWjFwioCjCQODq1oBMWNzEsKzckHxAzYo5Sze7OPkMA3DAxVq4SSR8y+TRC2G
# cOd0JReZ1lPlhlPl9XI+z8OgtOPmQnLLiP9qzpTHwFze+sbqSn8cekduMZdLyHJk
# 3Niw3AnglU/WTzGsQAdch9SVV4LHifUnmwTf0i07iKtTlNkq3bx1iyWg7N7jGZAB
# RWT2mX+YAVHlK27t9n+WtYbn6cOJNX6LsH8xPVBRYAIRVkWsMyEAdoP9dqfaZzwX
# GmjuVQ931NhzHjjG+Efw118DXjk3Vq3qUI1re34zMMTRzZZEw82FupF3viXNR3DV
# OlS9JH4x5emfINa1uuSac6F4CeJCD1GakfS7D5ayNsaZ2e+sBUh62KVTlhEsQRHZ
# RwCTxbix1Y4iJw+PDNLc0Hf19qX2XiX0u2SM9CWTTjsz9SvCjIKSxCZFCNv/zpKI
# lsHx7hQNQHSMbKh0/wwn86uiIALEjazUszE0+X6rcObDfU4h/O/0vmbF3BMR+45r
# AZMAETJsRDPxHJCo/5XGhWdg/LoJ5XWBrODL44YNrN7FRnHEAAr06sflqZ8eeV3F
# uDKdP5h19WUnGWwO1H/ZjUzOoVGiV3gwggdxMIIFWaADAgECAhMzAAAAFcXna54C
# m0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZp
# Y2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAxODMy
# MjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjANBgkqhkiG9w0B
# AQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51
# yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMMtY0Tz3cywBAY
# 6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9
# cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130/o5Tz9bshVZN
# 7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDua
# Rr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7vnGpF1tnYN74
# kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2
# K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNOwTM5
# TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6EgrXY28MyTZk
# i1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9Q
# BXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZyacaue7e3Pmri
# Lq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUC
# BBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9y
# eS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUA
# YgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU
# 1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2Ny
# bC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIw
# MTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0w
# Ni0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cBMSRb4Z5yS/yp
# b+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulm
# ZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/SHUB2RjebYIM
# 9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECW
# OKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2FzLixre24/LAl4
# FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3Uw
# xTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9swFXSVRk2XPX
# fx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJXk+d0tBMdrVX
# VAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/AsGC
# onsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdCPSWU
# 5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEG
# ahC0HVUzWLOhcGbyoYIDWDCCAkACAQEwggEBoYHZpIHWMIHTMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# Tjo0MDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaIjCgEBMAcGBSsOAwIaAxUAhGNHD/a7Q0bQLWVG9JuGxgLRXseggYMw
# gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQsF
# AAIFAOr7HOgwIhgPMjAyNDEyMDQxODI0NDBaGA8yMDI0MTIwNTE4MjQ0MFowdjA8
# BgorBgEEAYRZCgQBMS4wLDAKAgUA6vsc6AIBADAJAgEAAgFTAgH/MAcCAQACAhLu
# MAoCBQDq/G5oAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAI
# AgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAD9AWOueIp2A
# lWIKzCMx7zNb1nPrnf5wy0iU/1eu05SsozjVNRDyY03qm6dtic7MaxDwYudm/DaR
# zeZhzZmJWTUbyKzF0j9IZs5AUrSizvAVmTAUWKCKVj9RYoHN2XGz0MQxacaucgJ0
# b3tTvutkAt88/BDCm65Dlw+rA59NlRLIEhf5qZd5zz4hKD2f9LcvyFeCC45FtWvi
# pS3W0y2BvPJ1EQJrR5/58L87exI+mZPSg/mJ7AwSy7/xGr3qh4WDeEZfOJhA0NDu
# 4bFCXSEpdnmruA6z8CvjwY1VRlnQW7u7k1tHRryoWz21eRGfBL1chkCpnOAKCdzc
# zYfMXwRQoAwxggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMAITMwAAAf7QqMJ7NCELAQABAAAB/jANBglghkgBZQMEAgEFAKCCAUowGgYJ
# KoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCBxjrmWkaKD
# HE3UcS2Lvk/9ArtjVlYvTHjrbk7ODIaKkTCB+gYLKoZIhvcNAQkQAi8xgeowgecw
# geQwgb0EIBGFzN38U8ifGNH3abaE9apz68Y4bX78jRa2QKy3KHR5MIGYMIGApH4w
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAH+0KjCezQhCwEAAQAA
# Af4wIgQg/jbTKzH76KExFEDOoi1UjCqj2KMlJplnCxsyp1Fvks4wDQYJKoZIhvcN
# AQELBQAEggIAVZ5EkNNEBtY0BcjUvsJh+pX/+aVIXS9weh+OD3nFUfKRwW6EEdMN
# fNYirs0DARmjT6Mg/3aROkfW0M3LhReb4R92yZKnwxodiF/1kLwNOLRuYQKx0T3w
# 83WvZPLmaBHu0SKaLR6et9b7SHlCLKBrjtnadBLm6dt0v4QQjkd1MO1mNqrJdP1v
# hI9WrggukDG4L93BqNpjBvu0U8QjIrnzzm5LS3yg95isb11Hp1BBqXk5T0GQDO3X
# Qy78S4wEKbvf2hvc42ggUVkY9OULi34FoJoUiWUvg3wsUt9yNQwGJBuo6XEJVvC5
# QHkZBWwW5om8nkig8mS7gN76shgRLA50gjATRaCe91aowD7yOou2eMmFLQ/sAp6i
# 6ldgCKWTV429heSLFXl2GbqMPdZj7LFl5blq5JeLibI1iOFZ8wrzccbGWtHjs1wt
# 3IXyJfCIc6+hRsLlhLzCKlXa5oyiU2vU+6VntI35gJ0hEg+FiTQ3rtx0edn2c8f6
# tEJucEANwkKmyWx7nLOPmFf/qAWgcoEUNeX7icGl5/wCOcx99Fg/mPLY3XFfBpG9
# 8QRL/udrrJfKd/NR5Gtf45wHSEdz+mq81Rwd7jB350nxoX8EqS6Z0j44wl9Z8YCS
# YaXF8XWFTAZsP5bIwn6/t5RhuxIe7rnofTz5huJEbh6jYx4GkLTyioo=
# SIG # End signature block
