# macOS-onboard

![build](https://github.com/rajasoun/mac-onboard/actions/workflows/pipeline.yml/badge.svg)

macOS onboard tooling for Developers.

## Summary

Automation tooling does the following 
1. Checks for Pre Conditions
2. Setup, Upgrade and Teardown 
3. End To End Automation Tests
4. Git Configuration and Login

<details>
<summary>Pre Checks</summary>

- Containerization - 
   - Check macOS Version for Compatibility >=10.15
   - RAM Size > 4 GB
   - VirtualBox <= 4.3.30 must not be installed as it is not compatible with Docker Desktop
   - Download [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/) Binary based on Chipset Type and install in headless mode
    - Check buildkit is set to false for Apple Chip in ~/.docker/daemon.json
   - [Xcode Tools](https://developer.apple.com/xcode/) 
</details>

<details>
<summary>Setup and Teardown - Apps & Tools</summary>

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
1. Editors 
    - Visual Studio Code [Extensions](https://code.visualstudio.com/docs/editor/extension-marketplace)
        - [ms-vscode-remote.remote-containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) - [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)

</details>

# Gedtting Started

<details>
<summary>1. Workspace </summary>

In macOS Terminal Window, Run following commands for workspace setup

```sh
mkdir -p ${HOME}/workspace
cd ${HOME}/workspace
git clone https://github.com/rajasoun/mac-onboard
cd mac-onboard
```
</details>

<details>
<summary>2. Prerequisites Checks</summary>
In macOS Terminal Window, Run Prerequisites Checks 

```sh
./assist.sh pre-checks
```
</details>

<details>
<summary>3. SpeedTest via Docker</summary>
In macOS Terminal Window, Run Prerequisites Checks for Docker

```sh
./assist.sh speed-test
```
</details>

<details>
<summary>4. Teardown </summary>
In macOS Terminal Window, Run following command to teardown the existing setup (if any)

```sh
./assist.sh teardown # Will remove all packages
```
</details>

<details>
<summary>5. Setup </summary>
In macOS Terminal Window, Run following commands for application installation

```sh
./assist.sh setup
```
</details>

<details>
<summary>6. End To End (e2e) Tests  </summary>
In macOS Terminal Window, Run following commands for application installation end to end tests

```sh
./assist.sh test
```
</details>

<details>
<summary>7. Git Config </summary>
In macOS Terminal Window, Run following commands for git configuration

```sh
./assist.sh git-config
```
</details>

<details>
<summary>8. Git Login </summary>
In macOS Terminal Window, Run following commands for git Login via Token

```sh
export $(grep -v '^#' env.ini | xargs)
gh auth login --hostname $GIT --git-protocol ssh 
```

Store the token in github.token file and Validate via 

```sh
./assist.sh git-login
```
</details>

<details>
<summary>9. Sharing Test Output </summary>

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
