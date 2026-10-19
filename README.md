# PowerShell Execution Investigation

Investigating PowerShell execution in Splunk: routine inventory, an encoded inventory command, and an encoded launcher that downloads and runs a local sample.

The comparison focuses on what the command actually does. An encoded argument, hidden window or unsigned file can justify a closer look; the process chain, recorded script content, network activity and file output provide the context.

![PowerShell investigation in Splunk](images/splunk-overview.png)

## Cases

| Case | Launcher PID | Exit code |
| --- | ---: | ---: |
| inventory | 3328 | 0 |
| encoded-inventory | 2296 | 0 |
| download-execution | 2644 | 0 |

- **Inventory:** reads local system information and writes an inventory file.
- **Encoded inventory:** performs the same kind of local inventory through `-EncodedCommand`. This is the control for encoding alone.
- **Download and execution:** uses an encoded launcher and a hidden window, retrieves `check.ps1` from the lab HTTP service, then starts another PowerShell process to run it. The sample writes a harmless local marker.

## Investigation

The investigation traces each launcher through Sysmon process events, decodes the UTF-16LE command, checks PowerShell 4104, and correlates the download with file creation and the child process. Security 4688 provides a second view of process creation.

![Native Windows process evidence](images/windows-processes.png)

The selected source evidence contains **19 Windows records**. The downloaded file matches the supplied sample, SHA256 `634266e42d9ac4732db2130198f227f08fa79888cedf7b48bce4b7f5f239bb0d`. The full command lines and recorded content are retained in the evidence rather than truncated to the dashboard display.

![Native file hash inspection](images/windows-downloaded-file.png)

![Case output files](images/windows-output.png)

## Files

- [Investigation notes](docs/investigation.md)
- [Build and reproduce](docs/reproduce.md)
- [Evidence index](evidence/README.md)
- [SPL searches](splunk/searches/01-process-timeline.spl) and [Splunk dashboard](splunk/app/default/data/ui/views/investigation.xml)

This is an isolated lab investigation using safe payloads. The download chain is a behavior to investigate, not evidence of a real compromised company endpoint.
