# Download Script

```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://raw.githubusercontent.com/vkothapallirli/FIDScripts/main/installation/7.3/Windows/install.ps1 -OutFile $HOME\Desktop\install.ps1
```

# Example Usage


```
>.\install.ps1
Enter FID version (>=7.3.X): 7.3.15
Ener RLI_HOME path: c:\radiantone\vds
Enter cluster name: cluster1
Enter password: ******
Re-enter password: ******
Enter license: ********
```

```
>.\install.ps1 7.3.15 c:\radiantone\vds cluster1 "password" "license"
```
