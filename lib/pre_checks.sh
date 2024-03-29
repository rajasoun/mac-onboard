#!/usr/bin/env bash

# Prompt to User for Continue or Exit
function _prompt_confirm() {
  # call with a prompt string or use a default
  local response msg="${1:-${ORANGE}Do you want to continue${NC}} (y/[n])? "
  if test -n "$ZSH_VERSION"; then
    read -q "response?$msg"
  elif test -n "$BASH_VERSION"; then
    shift
    read -r "$@" -p "$msg" response || echo
  fi

  case "$response" in
  [yY][eE][sS] | [yY])
    return 0
    ;;
  [nN][no][No] | [nN])
    echo -e "${BOLD}${RED}Exiting setup${NC}\n"
    exit 1
    ;;
  *)
    return 1
    ;;
  esac
}

# converts version into digits
# example: version 1.1.1 -> 1001001000
function version {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

# Check if command installed
function check_command_installed(){
    cmd=$1
    if command -v $cmd >/dev/null 2>&1; then
        echo "Installed"
        return 0
    else
        echo "NOT Installed"
        return 1
    fi
}

# macOS Version >= 10.11
function check_mac_os_version(){
    os_version=$(sw_vers -productVersion)
    if [ $(version $os_version) -ge $(version "10.15") ]; then
        echo -e "${GREEN}\n1.1 macOS version $os_version${NC} - ✅ Condition >= 10.15\n"
    else
        echo -e "${RED}\n1.1 macOS version $os_version${NC}- ❌ Condition >= 10.15\n"
    fi

}

# RAM Size >= 4 GB
function check_mac_ram_size(){
    ram_size=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}')
    if [ $ram_size -ge 4 ]; then
        echo -e "${GREEN}1.2 RAM size $ram_size GB${NC} - ✅ Condition >= 4 GB\n"
    else
        echo -e "${GREEN}1.2 RAM size $ram_size GB${NC} - ❌ Condition >= 4 GB\n"
    fi
}

function check_mac_disk_size(){
    disk_size_used_percentage=$(df -h | awk '$NF=="/"{printf " %d\n", $5}')
    if [ $disk_size_used_percentage -le  60 ]; then
        echo -e "${GREEN}1.3 Disk Usage $disk_size_used_percentage % ${NC} - ✅ Condition <= 60 %\n"
    else
        echo -e "${GREEN}1.3 Disk Usage $disk_size_used_percentage % ${NC} - ❌ Condition > 60 %\n"
    fi
}

# If virtual box installed should be > 4.3.30
function check_virtual_box_installed_version(){
    if [ command -v vboxmanage  >/dev/null 2>&1 ]; then
        echo -e "${ORANGE}1.4 Virtual Box Installation Found - 🟠 ${NC}"
        vbox_version=$(vboxmanage --version)
        if [ $(version $vbox_version) -gt $(version "4.3.30") ]; then
            echo -e "   ${GREEN}1.4.1 Virtual Box version $vbox_version${NC} - ✅ Condition > 4.3.30\n"
        else
            echo -e "   ${RED}1.4.1 Virtual Box version $vbox_version${NC} - ❌ Condition > 4.3.30\n"
        fi
    else
        echo -e "${GREEN}1.4 Virtual Box Installation NOT Found ${NC}\n"
    fi
}

function docker_install_prompt(){
    chip_type=$1
    if [[ $(check_command_installed "docker") = "NOT Installed" ]]; then
        echo -e "\n1.5 Machine $(hostname) Chip Type is $chip_type"
        echo -e "   Download Docker Desktop for $chip_type Chip"
        echo -e "   https://docs.docker.com/desktop/mac/install/\n"
        _prompt_confirm "   ${ORANGE}Is Docker Desktop for $chip_type Chip Installation Done - Continue ? ${NC}"
    else
        echo -e "${GREEN}1.5 Docker Desktop for $chip_type Chip${NC} - ✅"
    fi
}

function buildkit_config(){
    buildkit_config=$(cat ~/.docker/daemon.json | grep buildkit | awk {'print $2'})
    if [ $buildkit_config = "true" ];then
        echo "true"
    else
        echo "false"
    fi
}

function check_mac_chipset(){
    chip_set_type=$(sysctl -n machdep.cpu.brand_string)
    choice=$( tr '[:upper:]' '[:lower:]' <<<"$chip_set_type" )
    case ${choice} in
        *"intel"*)
            docker_install_prompt "Intel"
            msg="1.5.1 buildkit Config Check"
            # In File $HOME/.docker/daemon.json
            if [ $(buildkit_config) = "true" ];then
                echo -e "   ${GREEN}$msg - Condition buildkit=true in $HOME/.docker/daemon.json ✅${NC}\n"
            else
                echo -e "   ${RED}$msg - Condition buildkit=false ❌${NC}\n"
                echo -e "   ${ORANGE}Change Config to true in Docker Desktop Settings ${NC}\n"
            fi
        ;;
        *"apple"*)
            docker_install_prompt "Apple"
            msg="1.5.1 buildkit Config Check"
            if [ $(buildkit_config) = "false" ];then
                echo -e "   ${GREEN}$msg - Condition buildkit=false in $HOME/.docker/daemon.json ✅${NC}\n"
            else
                echo -e "   ${RED}$msg - Condition buildkit=true in $HOME/.docker/daemon.json is true ❌${NC}\n"
                echo -e "   ${ORANGE}Change Config to false in Docker Desktop Settings ${NC}\n"
            fi
            # Docker Desktop > 4.12.0 (85629) Does Not Require Rosetta
            #echo -e "   1.4.2 Rosetta 2 Install For Apple Chip"
            #softwareupdate --install-rosetta
        ;;
        "*")
            echo -e "1.5 Machine $(hostname) Chip Type is ${RED}UNSUPPORTED${NC}."
            echo -e "Exiting..."
            exit 1
        ;;
    esac
}


function prerequisite_checks(){
    check_mac_os_version
    check_mac_ram_size
    check_mac_disk_size
    check_virtual_box_installed_version
    check_mac_chipset
}

function upgrade_xcode(){
    # find the CLI Tools update
    echo -e "   ${ORANGE}2.1 Check For Xcode CLI version updates...${NC}"
    PROD=$(softwareupdate -l    | \
        grep "\*.*Command Line" | \
                    head -n 1   | \
         awk -F"*" '{print $2}' | \
               sed -e 's/^ *//' | tr -d '\n') || true
    # install it
    if [[ ! -z "$PROD" ]]; then
        softwareupdate -i "$PROD" --verbose
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ];then
            echo -e "   ${GREEN}2.2 Xcode CLI version update - ✅${NC}"
        else
            echo -e "   ${GREEN}2.2 Xcode CLI version update - ❌${NC}"
        fi
    fi
}

function check_install_upgrade_xcode(){
    if [ $(check_command_installed "xcode-select") = "Installed" ]; then
        xcode_version=$(xcode-select --version)
        echo -e "${GREEN}2 Xcode [$xcode_version] Found${NC} - ✅ Xcode"
        upgrade_xcode
    else
        echo -e "${RED}2 Xcode Not Found - 🟠 ${NC}\n"
        xcode-select --install
    fi
    echo -e "\n"
}

function speed_test(){
    echo -e "\nDocker Speed Test - ✅ \n"
    MSYS_NO_PATHCONV=1  docker run --rm rajasoun/speedtest:0.1.0 "/go/bin/speedtest-go"
    echo -e "\n"
}

function pre_checks_main(){
    prerequisite_checks
    check_install_upgrade_xcode
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then
    echo -e "Executing $0 \n"
    pre_checks_main
fi
