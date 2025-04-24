# SpeedTest-Powershell
Powershell script that used Speedtest-CLI to give you results

```powershell
.\SpeedtestCLI-PS.ps1
```

$SaveLog, set to false to disable txt log, default is c:\temp 

$SaveJson, set to false to disable json log, default is c:\temp  

$TargetFolder, change to your desired location, default is c:\temp 

$EnableCleanup, change to clean up zip, exe, and md file from the SpeedTest-CLI. It will keep the folder and logs.

This will make a folder call speedtest under the target folder where everything is saved. 

```
Official Speedtest CLI from Ookla is provided under an End User License Agreement that limits its use “for your personal, non-commercial use on a single personal computer.” Running it on corporate machines—even for troubleshooting—would fall outside “personal, non-commercial use” and thus violate the EULA 

For business or enterprise environments, Ookla offers paid solutions (e.g., Speedtest Custom™, Speedtest Server, and other enterprise offerings) that are licensed for commercial use and provide additional features and reporting suited to network-wide diagnostics 

If you need to integrate internet-speed testing into corporate workflows, you should engage with Ookla’s sales or licensing teams to procure the appropriate enterprise license rather than using the free CLI.

If procuring an enterprise license isn’t an option, consider alternative tools that are open-source or have permissive licenses, such as:

LibreSpeed – a self-hosted speed-test server/client under an open-source license.

Fast.com CLI – Netflix’s CLI speed-test tool, free for both personal and commercial use.

iperf3 – a point-to-point network-throughput testing tool that you can run between any two endpoints on your network.

These options avoid EULA restrictions and can often be used freely in commercial settings 

Finally, remember that corporate networks often sit behind firewalls, proxies, or strict ACLs. You may need to allow outbound connections on TCP/UDP ports used by the chosen tool (e.g., HTTP/HTTPS for web-based tests or the default TCP/UDP port 5201 for iperf3) and ensure DNS resolution of test-server hostnames. Checking with your network/security team upfront can save time during troubleshooting.

```
