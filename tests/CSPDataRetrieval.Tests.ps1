# Import the function to be tested.
. "$PSScriptRoot/../code/CSPDataRetrieval.ps1"

Describe 'Get-ValidatedStorageAccountName' {
    # Mock Write-Host to capture output
    $writeHostMessages = [System.Collections.Generic.List[string]]::new()
    Mock Write-Host {
        param($Message)
        $writeHostMessages.Add($Message)
    } -Verifiable

    BeforeEach {
        $writeHostMessages.Clear()
    }

    Context 'When a valid name is provided on the first attempt' {
        It 'Should return the valid name' {
            Mock Read-Host { 'validname' } -Verifiable
            $result = Get-ValidatedStorageAccountName
            $result | Should -Be 'validname'
            $writeHostMessages.Count | Should -Be 0
        }
    }

    Context 'When an invalid name is provided, followed by a valid name' {
        It 'Should reject a name that is too short' {
            $inputs = @('ab', 'validname')
            $i = 0
            Mock Read-Host { $inputs[$i++] }
            $result = Get-ValidatedStorageAccountName
            $result | Should -Be 'validname'
            $writeHostMessages.Count | Should -Be 1
            $writeHostMessages[0] | Should -Be 'Input was invalid. The name must be between 3 and 24 characters long. Please try again with another name.'
        }

        It 'Should reject a name that is too long' {
            $inputs = @('thisnameislongerthan24characters', 'validname')
            $i = 0
            Mock Read-Host { $inputs[$i++] }
            $result = Get-ValidatedStorageAccountName
            $result | Should -Be 'validname'
            $writeHostMessages.Count | Should -Be 1
            $writeHostMessages[0] | Should -Be 'Input was invalid. The name must be between 3 and 24 characters long. Please try again with another name.'
        }

        It 'Should reject a name with uppercase letters' {
            $inputs = @('InvalidName', 'validname')
            $i = 0
            Mock Read-Host { $inputs[$i++] }
            $result = Get-ValidatedStorageAccountName
            $result | Should -Be 'validname'
            $writeHostMessages.Count | Should -Be 1
            $writeHostMessages[0] | Should -Be 'Input was invalid. The name can only contain lowercase letters and numbers. Please try again with another name.'
        }

        It 'Should reject a name with special characters' {
            $inputs = @('invalid-name', 'validname')
            $i = 0
            Mock Read-Host { $inputs[$i++] }
            $result = Get-ValidatedStorageAccountName
            $result | Should -Be 'validname'
            $writeHostMessages.Count | Should -Be 1
            $writeHostMessages[0] | Should -Be 'Input was invalid. The name can only contain lowercase letters and numbers. Please try again with another name.'
        }

        It 'Should reject empty input' {
            $inputs = @('', 'validname')
            $i = 0
            Mock Read-Host { $inputs[$i++] }
            $result = Get-ValidatedStorageAccountName
            $result | Should -Be 'validname'
            $writeHostMessages.Count | Should -Be 1
            $writeHostMessages[0] | Should -Be 'No input was provided. Please try again.'
        }
    }
}
