# macOS-onboard

macOS Laptop setup for Developer with Docker Desktop & Applications. The primary purpose is to have a standard way of configuring a development environment that is simple, fast and completely automated.

## Application & Tools Summary

Following Applications & Tools are setup/teardown from the automation script

<details>
<summary>Containerization - Docker Desktop for Mac</summary>

- Containerization - [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
   - Check macOS Version for Compatibility >=10.15
   - RAM Size > 4 GB
   - VirtualBox <= 4.3.30 must not be installed as it is not compatible with Docker Desktop
   - Download Docker Desktop Binary based on Chipset Type and install in headless mode
    - If Chipset type is Apple Silicon, install Rosetta 2
    - Check buildkit is set to false for Apple Chip in ~/.docker/daemon.json
</details>

<details>
<summary>XCode for Mac</summary>

- [Xcode Tools](https://developer.apple.com/xcode/)
</details>

<details>
<summary>Applications & Tools</summary>

1. Package Manager - [Homebrew](https://brew.sh/)
    - Nix Tools
        - zsh
        - zsh-autosuggestions - Suggests commands as you type based on history and completions.
        - zsh-syntax-highlighting - Syntax highlighter for the Zsh shell
        - [coreutils](https://www.gnu.org/software/coreutils/) -  File, shell and text manipulation utilities
    - Internet Tool
        - ca-certificates - [Digital Certificate](https://i.stack.imgur.com/mR9xE.png) issued by a certificate authority (CA), so SSL clients (such as wget, curl, httpie) can use it to verify the SSL certificates sign by this CA
        - wget - Retrieving files using HTTP, HTTPS, FTP and FTPS
        - curl - Transferring data with URLs
        - openssl - General-purpose cryptography for secure communication.
        - netcat - Networking utility which reads and writes data across networks
        - [httpie](https://httpie.io/) - Command-line HTTP and API testing client
    - Programming Languages
        - [go](https://go.dev/)
        - [python@3.10](https://www.python.org/)
        - [node](https://nodejs.org/en/)
    - Programming Tools
        - [gh](https://github.com/cli/cli) - GitHub on the command line
        - [jq](https://stedolan.github.io/jq/) - sed for JSON data
    - Terminal Productivity Tools
        - [asciinema](https://asciinema.org/) - Recording terminal sessions and sharing them on the web
1. Visual Studio Code [Extensions](https://code.visualstudio.com/docs/editor/extension-marketplace)
   - [ms-vscode-remote.remote-containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) - [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)
   - [golang.go](https://marketplace.visualstudio.com/items?itemName=golang.Go)

</details>

# Automation

Automation script does following Prerequisites Checks, Setup and Tests

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

## 3. Test
<details>
<summary>1. End To End (e2e) Tests  </summary>
In macOS Terminal Window, Run following commands for application installation

```sh
./assist.sh test
```
</details>

<details>
<summary>2. Sharing Test Output </summary>

Execute using `script` command and share the log.txt

```sh
script log.txt ./assist.sh teardown
script log.txt ./assist.sh setup
script log.txt ./assist.sh test
script log.txt ./assist.sh pre-checks
script log.txt ./assist.sh speed-test
script log.txt ./assist.sh check
```
</details>
