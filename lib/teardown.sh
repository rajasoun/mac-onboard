#!/usr/bin/env bash

function uninstall_visual_studio_code_on_mac(){
    # Uninstall Visual Studio for Mac
    echo "Uninstalling Visual Studio for Mac..."
    sudo rm -rf "/Applications/Visual Studio.app"
    rm -rf ~/Library/Caches/VisualStudio
    rm -rf ~/Library/Preferences/VisualStudio
    rm -rf ~/Library/Preferences/Visual\ Studio
    rm -rf ~/Library/Logs/VisualStudio
    rm -rf ~/Library/VisualStudio
    rm -rf ~/Library/Preferences/Xamarin/
    rm -rf ~/Library/Application\ Support/VisualStudio
    rm -rf ~/Library/Application\ Support/VisualStudio/7.0/LocalInstall/Addins/
    # Uninstall Xamarin.Android
    echo "Uninstalling Xamarin.Android..."
    sudo rm -rf /Developer/MonoDroid
    rm -rf ~/Library/MonoAndroid
    sudo pkgutil --forget com.xamarin.android.pkg
    sudo rm -rf /Library/Frameworks/Xamarin.Android.framework
    # Uninstall Xamarin.iOS
    echo "Uninstalling Xamarin.iOS..."
    rm -rf ~/Library/MonoTouch
    sudo rm -rf /Library/Frameworks/Xamarin.iOS.framework
    sudo rm -rf /Developer/MonoTouch
    sudo pkgutil --forget com.xamarin.monotouch.pkg
    sudo pkgutil --forget com.xamarin.xamarin-ios-build-host.pkg
    # Uninstall Xamarin.Mac
    echo "Uninstalling Xamarin.Mac..."
    sudo rm -rf /Library/Frameworks/Xamarin.Mac.framework
    rm -rf ~/Library/Xamarin.Mac
    # Uninstall Workbooks and Inspector
    echo "Uninstalling Workbooks and Inspector..."
    if [ -f "/Library/Frameworks/Xamarin.Interactive.framework/Versions/Current/uninstall" ]; then
        sudo /Library/Frameworks/Xamarin.Interactive.framework/Versions/Current/uninstall
    fi
    # Uninstall the Visual Studio for Mac Installer
    echo "Uninstalling the Visual Studio for Mac Installer..."
    rm -rf ~/Library/Caches/XamarinInstaller/
    rm -rf ~/Library/Caches/VisualStudioInstaller/
    rm -rf ~/Library/Logs/XamarinInstaller/
    rm -rf ~/Library/Logs/VisualStudioInstaller/
    # Uninstall the Xamarin Profiler
    echo "Uninstalling the Xamarin Profiler..."
    sudo rm -rf "/Applications/Xamarin Profiler.app"
    echo "Finished Uninstallation process."
}

function uninstall_visual_studio_code_extension(){
    if command -v code >/dev/null 2>&1; then
        code --list-extensions | xargs -L 1 code --uninstall-extension
    else
        echo -e "Visual Studio Code Extension Already Removed"
    fi
}

function backup_remove_dot_files(){
    # .zshrc and .zprofile 
    if [ -f ${HOME}/.zshrc ]; then 
        mv ${HOME}/.zshrc ${HOME}/.zshrc.backup
    fi 
    
    if [ -f ${HOME}/.zprofile ]; then 
        mv ${HOME}/.zprofile ${HOME}/.zprofile.backup
    fi 
}

function teardown(){
    # multipass 
    # to destroy all data, too
    brew uninstall --zap multipass

    # visual studio code
    if command -v code >/dev/null 2>&1; then
        uninstall_visual_studio_code_extension
        uninstall_visual_studio_code_on_mac
    else
        echo -e "Visual Studio Code Already Uninstalled"
    fi
    python3_version=$(python3 --version)
    if [ $(version $python3_version) -ge $(version "3.30") ]; then
        # python3 global packages
        if command -v pip3 >/dev/null 2>&1; then
            pip3 freeze | xargs pip3 uninstall -y
        else
            echo -e "Python3 Global Packages Already Uninstalled"
        fi
    else
        echo -e "Python3 Already Uninstalled"
    fi

    # Remove Node packages 
    if command -v npm >/dev/null 2>&1; then
        NODE_PACKAGES=($(cat packages/node_packages.txt))
        npm uninstall -g ${NODE_PACKAGES[@]}
    fi 
    
    # brew
    if command -v brew >/dev/null 2>&1; then
        brew list | xargs brew uninstall --force
        brew list --cask | xargs brew uninstall --force
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    else
        echo -e "Homebrew Already Uninstalled"
    fi
    # zsh, themes and plugins
    sudo /bin/rm -fr /usr/local/bin/sentry-cli
    /bin/rm -fr $HOME/.oh-my-zsh
    /bin/rm -fr  /usr/local/share/zsh-autosuggestions
    /bin/rm -fr  /usr/local/share/zsh-syntax-highlighting
    backup_remove_dot_files
}

function teardown_main(){
    start=$(date +%s)
    teardown
    EXIT_CODE="$?"
    end=$(date +%s)
    runtime=$((end-start))
    MESSAGE="Mac Onboarding - Teardown | $USER | Duration: $(_display_time $runtime) "
    log "$EXIT_CODE" "$MESSAGE"
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then
    echo -e "Executing $0 "
    teardown_main
fi
