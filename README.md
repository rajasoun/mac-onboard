# Getting Started

1. Bootstrap MacOS to use Visual Studio Code DevContainer
    * Open Terminal Window and run following commands

        ```sh
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
