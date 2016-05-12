$global:DSCModuleName = 'xWebAdministration'
$global:DSCResourceName = 'MSFT_xIISFeatureDelegation'

#region HEADER

[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
$repoSource = (Get-Module -Name $global:DSCModuleName -ListAvailable)

if ($repoSource.RepositorySourceLocation.Host -eq 'www.powershellgallery.com') {
    if ( -not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DscResourceTestHelper')) ) {
        #install test folders from gallery
        Save-Module -Name 'DscResourceTestHelper' -Path $moduleRoot
    }

    $testModuleVer = '0.2.0.0'
    Import-Module (Join-Path -Path $moduleRoot -ChildPath "DscResourceTestHelper\$testModuleVer\TestHelper.psm1") -Force
} 
elseif ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DscResource.Tests'))) -or `
        (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DscResource.Tests\DscResourceTestHelper'))) -or `
       (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DscResource.Tests\DscResourceTestHelper\TestHelper.psm1'))) ) {
    #clone test folders from gitHub
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DscResource.Tests\'))

    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DscResource.Tests\DscResourceTestHelper\TestHelper.psm1') -Force
}
else {
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DscResource.Tests\DscResourceTestHelper\TestHelper.psm1') -Force
}


$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $DSCResourceName {

        #region Function Get-TargetResource
        Describe 'MSFT_xIISFeatureDelegation\Get-TargetResource' {
            Context 'OverRideMode is present' {
                Mock Get-OverrideMode {return 'Allow'}
                $result = Get-TargetResource -SectionName 'serverRunTime' -OverRideMode 'Allow'
                $expected = @{
                    SectionName = 'serverRunTime'
                    OverrideMode = 'Allow'
                    Ensure = 'Present'
                }
                It 'should return the correct hashtable' {
                    $result.SectionName  | Should Be $expected.SectionName
                    $result.OverrideMode | Should Be $expected.OverrideMode
                    $result.Ensure       | Should Be $expected.Ensure
                }
            }
            Context 'OverRideMode is absent' {
                Mock Get-OverrideMode {return 'Deny'}
                $result = Get-TargetResource -SectionName 'serverRunTime' -OverRideMode 'Allow'
                $expected = @{
                    SectionName = 'serverRunTime'
                    OverrideMode = 'Deny'
                    Ensure = 'Absent'
                }
                It 'should return the correct hashtable' {
                    $result.SectionName  | Should Be $expected.SectionName
                    $result.OverrideMode | Should Be $expected.OverrideMode
                    $result.Ensure       | Should Be $expected.Ensure
                }
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe 'MSFT_xIISFeatureDelegation\Test-TargetResource' {
            Context 'OverRideMode is present' {
                Mock Get-OverrideMode {return 'Allow'}
                It 'should return true' {
                    $results = Test-TargetResource -SectionName 'serverRunTime' -OverRideMode 'Allow'
                    $results | Should Be $true
                }
            }

            Context 'OverRideMode is absent' {
                Mock Get-OverrideMode {return 'Allow'}
                It 'should return true' {
                    $results = Test-TargetResource -SectionName 'serverRunTime' -OverRideMode 'Deny'
                    $results | Should Be $false
                }
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe 'MSFT_xIISFeatureDelegation\Set-TargetResource' {
            # TODO: Add Set-TargetResource tests
        }
        #endregion

        Describe 'MSFT_xIISFeatureDelegation\Get-OverrideMode' {
            Context 'function is not able to find a value' {
                It 'Should throw an error on null' {
                    Mock Get-WebConfiguration {return $null}
                    {Get-OverrideMode -Section 'NonExistant'} | Should Throw
                }

                It 'Should throw an error on the wrong value' {
                    Mock Get-WebConfiguration {return 'Wrong'}
                    {Get-OverrideMode -Section 'NonExistant'} | Should Throw
                }
            }
        }

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
