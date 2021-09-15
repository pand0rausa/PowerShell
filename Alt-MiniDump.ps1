
None selected 

Skip to content
Using Gmail with screen readers
Meet
New meeting
Join a meeting
Hangouts

Conversations
66.56 GB of 102 GB used
Terms · Privacy · Program Policies
Last account activity: 56 minutes ago
Details
# encoding: ascii
# api: powershell
# title: Write-MiniDump
# description: Actually, this is only an idea and I’m not sure that it’ll be useful because I usually use Sysinternals ProcDump tool (hello, Mark!)
# version: 0.1
# type: function
# author: greg zakharov
# license: CC0
# function: Write-MiniDump
# x-poshcode-id: 4740
# x-archived: 2015-10-25T15:14:05
# x-published: 2015-12-25T14:33:00
#
#
Set-Alias wmd Write-MiniDump

function Write-MiniDump {
  <#
    .SYNOPSIS
        Creates mini dump of trouble process.
    .EXAMPLE
        PS C:\>Write-MiniDump (ps notepad)
        Creates full memory dump of notepad process(es).
    .EXAMPLE
        PS C:\>ps notepad | wmd -dp E:\dbg -dt 0
        Creates normal dump of notepad process(es) into E:\dbg folder.
    .NOTES
        C++
        typedef enum _MINIDUMP_TYPE { 
          MiniDumpNormal                          = 0x00000000,
          MiniDumpWithDataSegs                    = 0x00000001,
          MiniDumpWithFullMemory                  = 0x00000002,
          MiniDumpWithHandleData                  = 0x00000004,
          MiniDumpFilterMemory                    = 0x00000008,
          MiniDumpScanMemory                      = 0x00000010,
          MiniDumpWithUnloadedModules             = 0x00000020,
          MiniDumpWithIndirectlyReferencedMemory  = 0x00000040,
          MiniDumpFilterModulePaths               = 0x00000080,
          MiniDumpWithProcessThreadData           = 0x00000100,
          MiniDumpWithPrivateReadWriteMemory      = 0x00000200,
          MiniDumpWithoutOptionalData             = 0x00000400,
          MiniDumpWithFullMemoryInfo              = 0x00000800,
          MiniDumpWithThreadInfo                  = 0x00001000,
          MiniDumpWithCodeSegs                    = 0x00002000,
          MiniDumpWithoutAuxiliaryState           = 0x00004000,
          MiniDumpWithFullAuxiliaryState          = 0x00008000,
          MiniDumpWithPrivateWriteCopyMemory      = 0x00010000,
          MiniDumpIgnoreInaccessibleMemory        = 0x00020000,
          MiniDumpWithTokenInformation            = 0x00040000,
          MiniDumpWithModuleHeaders               = 0x00080000,
          MiniDumpFilterTriage                    = 0x00100000,
          MiniDumpValidTypeFlags                  = 0x001fffff
        } MINIDUMP_TYPE;
  #>
  [CmdletBinding(DefaultParameterSetName="Process", SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipeline=$true)]
    [Diagnostics.Process[]]$Processes,
    
    [Parameter(Position=1)]
    [Alias("dp")]
    [ValidateScript({Test-Path $_})]
    [String]$DumpPath = $pwd.Path,
    
    [Parameter(Position=2)]
    [Alias("dt")]
    [ValidateSet(0, 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200, 0x400, 0x800, 0x1000,
                  0x2000, 0x4000, 0x8000, 0x10000, 0x200000, 0x40000, 0x80000, 0x100000, 0x1fffff)]
    [UInt32]$DumpType = 0x2
  )
  
  begin {
    $wer = [PSObject].Assembly.GetType('System.Management.Automation.WindowsErrorReporting')
    $get = $wer.GetNestedType('NativeMethods', 'NonPublic')
    $api = $get.GetMethod('MiniDumpWriteDump', ([Reflection.BindingFlags]'NonPublic, Static'))
  }
  process {
    foreach ($p in $Processes) {
      if ($PSCmdlet.ShouldProcess($p.Name, "Create mini dump")) {
        $dmp = Join-Path $DumpPath "$($p.Name)_$($p.Id)_$(date -u %d%m%Y).dmp"
        
        try {
          $str = New-Object IO.FileStream($dmp, [IO.FileMode]::Create)
          [void]$api.Invoke($null, @($p.Handle, $p.Id, $str.SafeFileHandle, $DumpType,
                                      [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero))
        }
        finally {
          if ($str -ne $null) {$str.Close()}
        }
      }
    }
  }
  end {
  }
}
minidump.txt
Displaying minidump.txt.
