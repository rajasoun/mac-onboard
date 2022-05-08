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
    - Run speed test 
    
    ```sh
    MSYS_NO_PATHCONV=1  docker run --rm rajasoun/speedtest:0.1.0 "/go/bin/speedtest-go"
    ```

1. Mac [Xcode](https://developer.apple.com/xcode/)
1. Package Manager -[brew](https://brew.sh/)
   - [Git Bash](https://git-scm.com/)
   - [GitHub CLI](https://cli.github.com/)
   - Code Editor (IDE) - [Visual Studio Code](https://code.visualstudio.com/)
1. Visual Studio Code [Extensions](https://code.visualstudio.com/docs/editor/extension-marketplace)
   - [ms-vscode-remote.remote-containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) - [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)
   - [golang.go](https://marketplace.visualstudio.com/items?itemName=golang.Go)

## 1. Prerequisites Checks

<details>
<summary>1 Docker Desktop for Mac</summary>
In macOS Terminal Window, Run Prerequisites Checks for Docker Desktop Installation

```sh
./assist.sh pre-checks
```
</details>

<details>
<summary>2 SpeedTest via Docker</summary>
In macOS Terminal Window, Run Prerequisites Checks for Docker

```sh
./assist.sh speed-test
```
</details>

## 2. Setup

<details>
<summary>1. Workspace & Applications</summary>
In macOS Terminal Window, Run following commands for workspace setup
```sh
mkdir -p workspace
cd workspace
git clone https://github.com/rajasoun/mac-onboard
cd mac-onboard
```
</details>

<details>
<summary>2. Teardown </summary>
In macOS Terminal Window, Run following command to teardown the existing setup
```sh
./assist.sh teardown # Will remove all packages
```
</details>

<details>
<summary>3. Setup </summary>
In macOS Terminal Window, Run following commands for application installation 
```sh
./assist.sh setup 
```
</details>

<details>
<summary>4. Test </summary>
In macOS Terminal Window, Run following commands for application installation 
```sh
./assist.sh test 
```
</details>

## Debugging

> Ensure No Credntials Gets Typed

Execute using `script` command and share the log.txt

```sh
script log.txt ./assist.sh teardown
script log.txt ./assist.sh setup
script log.txt ./assist.sh test
script log.txt ./assist.sh check
```
