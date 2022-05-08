# macOS-onboard

macOS Laptop setup for Developer with Docker Desktop & Applications. The primary purpose is to have a standard way of configuring a development environment that is simple, fast and completely automated.

Onboard Automation script configures and installs the following.

1. Containerization - [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
   - Check macOS Version for Compatibility >=10.15
   - RAM Size > 4 GB
   - VirtualBox <= 4.3.30 must not be installed as it is not compatible with Docker Desktop
   - Download Docker Desktop Binary based on Chipset Type and install in headless mode 
    - If Chipset type is Apple Silicon, install Rosetta 2
    - Check buildkit is set to false for Apple Chip in ~/.docker/daemon.json
1. Test Docker Setup 
    - Run speed test `MSYS_NO_PATHCONV=1  docker run --rm rajasoun/speedtest:0.1.0 "/go/bin/speedtest-go"`
1. Mac [Xcode](https://developer.apple.com/xcode/)
1. Package Manager -[brew](https://brew.sh/)
   - [Git Bash](https://git-scm.com/)
   - [GitHub CLI](https://cli.github.com/)
   - Code Editor (IDE) - [Visual Studio Code](https://code.visualstudio.com/)
1. Visual Studio Code [Extensions](https://code.visualstudio.com/docs/editor/extension-marketplace)
   - [ms-vscode-remote.remote-containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) - [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)
   - [golang.go](https://marketplace.visualstudio.com/items?itemName=golang.Go)

Refernces:

- Docker Desktop for Windows [Troubleshooting Guide](https://docs.docker.com/desktop/windows/troubleshoot/#virtualization-must-be-enabled)


1. Bootstrap MacOS to use Visual Studio Code DevContainer
    * Open Terminal Window and run following commands

        ```sh
        mkdir workspace
        cd workspace
        git clone https://github.com/rajasoun/mac-onboard
        cd mac-onboard
        ./assist.sh teardown # Will remove all packages
        ./assist.sh setup
        ./assist.sh test
        ```

    * On Sucess

        ```sh
        💯  All passed
        ```

    * On Failure - Review Failed Tests and Fix

        ```sh
        💥  Failed tests
        ```

1. Install [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
    * To Get Details about the Type of Chip
        ```sh
        sysctl -n machdep.cpu.brand_string
        ```

1. Test Docker Setup
    ```sh
    docker run --rm  hello-world
    ```

## Debugging

> Ensure No Credntials Gets Typed

Execute using `script` command and share the log.txt

```sh
script log.txt ./assist.sh teardown
script log.txt ./assist.sh setup
script log.txt ./assist.sh test
script log.txt ./assist.sh check
```
