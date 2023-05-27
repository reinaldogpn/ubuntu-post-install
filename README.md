# ubuntu-post-install.sh

### What it does

This script automatically installs every program I use in my PC, runs updates and does post install cleaning.

### Running

``` bash
bash <(curl -s https://raw.githubusercontent.com/reinaldogpn/ubuntu-post-install/main/ubuntu-post-install.sh) <param>
```

* _Replace ```<param>``` with parameter ```-f or --full``` for a full installation, or ```-s or --simple``` for a much simpler one (without games support for eg.)._

* _or you can download .sh file and run it by yourself:_

``` bash
chmod +x ubuntu-post-install.sh && bash ubuntu-post-install.sh <param>
```
