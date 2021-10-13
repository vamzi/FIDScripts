# Download Script

```
Invoke-WebRequest -Uri https://raw.githubusercontent.com/vkothapallirli/FIDScripts/main/installation/7.3/Windows/install.ps1 -OutFile $HOME\Desktop\install.p
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
