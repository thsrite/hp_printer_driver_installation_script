#!/bin/sh

echo ""
echo Welcome to the HP printer driver installation script
echo 欢迎使用惠普打印机驱动安装脚本
echo ""
echo This script requires password authorization to gain administrator privileges for proper execution
echo 此脚本需通过密码授权来获得管理员权限才能正常执行
echo ""
echo Please enter the password and press Enter
echo 请输入密码并按回车
echo ""
echo "Note: The password is the current user's lock screen login password, and the entered characters are invisible"
echo 注意：密码是当前用户的锁屏登录密码，并且输入的字符不可见
echo ""

while true; do
    if sudo -v 2>/dev/null; then
        break
    else
        echo "Sorry, try again." 
    fi
done

echo ""
echo "------------------------------"
echo ""

URL="https://ftp.hp.com/pub/softlib/software12/HP_Quick_Start/osx/Applications/ASU/HewlettPackardPrinterDrivers.dmg"
DEFAULT_DMG="$HOME/library/Caches/hp_printers_drives_installation_temp/HewlettPackardPrinterDrivers.dmg"
DOWNLOADS_DMG="$HOME/Downloads/HewlettPackardPrinterDrivers.dmg"
VOLUME_NAME="HP_PrinterSupportManual"
TEMP_DIR="$HOME/library/Caches/hp_printers_drives_installation_temp"

macos_version=$(sw_vers -productVersion)

for vol in /Volumes/HP_PrinterSupportManual\ [0-9]*; do
  if [ -d "$vol" ]; then
    hdiutil detach -force "$vol" >/dev/null 2>&1
  fi
done

if [ "$(printf '15.0\n%s' "$macos_version" | sort -V | tail -n1)" != "$macos_version" ] || [ "$macos_version" = "15.0" ]; then
    echo "(1/3)"
    echo ""
    echo "Checking if virtual disk image $VOLUME_NAME is mounted"
    echo "正在检查虚拟磁盘镜像 $VOLUME_NAME 是否已挂载"
    echo ""

    mkdir -p "$TEMP_DIR"

    EXPECTED_MD5="9fdcd238fd25b430f5498c60bd2277ff"

    check_md5() {
        local file=$1
        local md5=$(md5 -q "$file")
        if [ "$md5" = "$EXPECTED_MD5" ]; then
            return 0
        else
            return 1
        fi
    }

    if hdiutil info | grep -q "$VOLUME_NAME"; then
        echo "$VOLUME_NAME is mounted"
        echo "$VOLUME_NAME 已挂载"
        echo ""

        MOUNT_POINT=$(hdiutil info | grep "$VOLUME_NAME" | grep "/Volumes/" | awk '{$1=$2=""; print $0}' | sed 's/^[ \t]*//')
    else
        echo "Not mounted, checking the download directory and temporary directory for the existence of HewlettPackardPrinterDrivers.dmg"
        echo "未挂载，正在检查下载目录和临时目录否存在 HewlettPackardPrinterDrivers.dmg"
        echo ""

        if [ -f "$DOWNLOADS_DMG" ]; then
            echo "HewlettPackardPrinterDrivers.dmg found in Downloads"
            echo "HewlettPackardPrinterDrivers.dmg 在下载目录中找到"
            echo ""
        echo "Checking file integrity by verifying hash value"
        echo "正在通过校验哈希值来检查该文件是否完整"
        echo ""
            if check_md5 "$DOWNLOADS_DMG"; then
                DMG_FILE="$DOWNLOADS_DMG"
            echo HewlettPackardPrinterDrivers.dmg passed verification and the file is complete
                echo "HewlettPackardPrinterDrivers.dmg 通过校验，文件完整"
            echo ""
            else
                echo "HewlettPackardPrinterDrivers.dmg did not pass verification, the file is incomplete, and will start re-downloading from the apple cdn server"
                echo "HewlettPackardPrinterDrivers.dmg 未通过校验，文件不完整，开始从惠普 cdn 服务器重新下载"
                echo ""
                curl -L -o "$DEFAULT_DMG" "$URL"
		if [ $? -ne 0 ]; then
    	            echo "Unable to connect to HP CDN server, download failed"
	            echo 无法连接到惠普 cdn 服务器，下载失败
	            echo ""
                    exit 1
                fi
                DMG_FILE="$DEFAULT_DMG"
                echo "HewlettPackardPrinterDrivers.dmg download completed"
                echo "HewlettPackardPrinterDrivers.dmg 下载完成"
            echo ""
            fi

        elif [ -f "$DEFAULT_DMG" ]; then
            echo "HewlettPackardPrinterDrivers.dmg found in temp"
            echo "HewlettPackardPrinterDrivers.dmg 在临时目录中找到"
            echo ""
            echo "Checking file integrity by verifying hash value"
        echo "正在通过校验哈希值来检查该文件是否完整"
        echo ""
            if check_md5 "$DEFAULT_DMG"; then
                DMG_FILE="$DEFAULT_DMG"
                echo "HewlettPackardPrinterDrivers.dmg passed verification, the file is complete"
                echo "HewlettPackardPrinterDrivers.dmg 通过校验，文件完整"
            echo ""
            else
                echo "HewlettPackardPrinterDrivers.dmg did not pass verification, the file is incomplete, and will start re-downloading from the apple cdn server"
                echo "HewlettPackardPrinterDrivers.dmg 未通过校验，文件不完整，开始从惠普 cdn 服务器重新下载"
                echo ""
                curl -L -o "$DEFAULT_DMG" "$URL"
	  	if [ $? -ne 0 ]; then
    	            echo "Unable to connect to HP CDN server, download failed"
	            echo 无法连接到惠普 cdn 服务器，下载失败
	            echo ""
                    exit 1
                fi
                DMG_FILE="$DEFAULT_DMG"
            echo "HewlettPackardPrinterDrivers.dmg download completed"
                echo "HewlettPackardPrinterDrivers.dmg 下载完成"
            echo ""
            fi

        else
            echo "HewlettPackardPrinterDrivers.dmg not found, will start downloading from apple cdn server"
            echo "HewlettPackardPrinterDrivers.dmg 未找到，开始从惠普 cdn 服务器下载"
            echo ""
            curl -L -o "$DEFAULT_DMG" "$URL"
	    if [ $? -ne 0 ]; then
    	        echo "Unable to connect to HP CDN server, download failed"
	        echo 无法连接到惠普 cdn 服务器，下载失败
	        echo ""
                exit 1
            fi
            DMG_FILE="$DEFAULT_DMG"
        echo "HewlettPackardPrinterDrivers.dmg download completed"
            echo "HewlettPackardPrinterDrivers.dmg 下载完成"
        echo ""
        fi

        echo "Mounting $DMG_FILE"
        echo "正在挂载 $DMG_FILE"
        echo ""

        MOUNT_POINT=$(hdiutil attach "$DMG_FILE" | grep "$VOLUME_NAME" | awk '{print $3}')
        echo "$MOUNT_POINT is mounted"
        echo "$MOUNT_POINT 已挂载"
        echo ""
    fi


    echo "(2/3)"
    echo "Installing HewlettPackardPrinterDrivers.pkg"
    echo "正在安装 HewlettPackardPrinterDrivers.pkg"
    echo ""

    sudo installer -pkg "$MOUNT_POINT/HewlettPackardPrinterDrivers.pkg" -target /
    echo ""
    
    hdiutil detach -force "/Volumes/HP_PrinterSupportManual" > /dev/null 2>&1
    echo HP_PrinterSupportManual ejected
    echo HP_PrinterSupportManual 已推出
    echo ""

    sudo rm -rf "$DMG_FILE"
    echo "HewlettPackardPrinterDrivers.dmg has been deleted"
    echo "HewlettPackardPrinterDrivers.dmg 已删除"
    echo ""

    echo "(3/3)"
    echo ""
    echo "Checking whether temporary files are generated during the installation process"
    echo 正在检查安装过程中是否产生临时文件
    echo ""    
    if [ -d "$TEMP_DIR" ]; then
    	echo Temporary files detected and being cleared
    	echo 检查到有临时文件产生，正在将其清除
	echo ""
    	sudo rm -rf "$TEMP_DIR"
     	echo Temporary files cleared
	echo 临时文件已清除
	echo ""
    else
    	echo No temporary files were detected
	echo 未检查到有临时文件产生
	echo ""
    fi

    echo "------------------------------"
    echo ""

    echo HP printer driver has been installed successfully
    echo 惠普打印机驱动已安装成功
    echo ""
    echo This script has been fully executed, thank you for using
    echo 此脚本已全部执行完毕，感谢使用
    echo ""
    exit 0
    
else
    :
fi

echo "(1/7)"
echo ""
echo "Checking if virtual disk image $VOLUME_NAME is mounted"
echo "正在检查虚拟磁盘镜像 $VOLUME_NAME 是否已挂载"
echo ""

mkdir -p "$TEMP_DIR"

EXPECTED_MD5="9fdcd238fd25b430f5498c60bd2277ff"

check_md5() {
    local file=$1
    local md5=$(md5 -q "$file")
    if [ "$md5" = "$EXPECTED_MD5" ]; then
        return 0
    else
        return 1
    fi
}

if hdiutil info | grep -q "$VOLUME_NAME"; then
    echo "$VOLUME_NAME is mounted"
    echo "$VOLUME_NAME 已挂载"
    echo ""

    MOUNT_POINT=$(hdiutil info | grep "$VOLUME_NAME" | grep "/Volumes/" | awk '{$1=$2=""; print $0}' | sed 's/^[ \t]*//')
else
    echo "Not mounted, checking the download directory and temporary directory for the existence of HewlettPackardPrinterDrivers.dmg"
    echo "未挂载，正在检查下载目录和临时目录否存在 HewlettPackardPrinterDrivers.dmg"
    echo ""

    if [ -f "$DOWNLOADS_DMG" ]; then
        echo "HewlettPackardPrinterDrivers.dmg found in Downloads"
        echo "HewlettPackardPrinterDrivers.dmg 在下载目录中找到"
        echo ""
    echo "Checking file integrity by verifying hash value"
    echo "正在通过校验哈希值来检查该文件是否完整"
    echo ""
        if check_md5 "$DOWNLOADS_DMG"; then
            DMG_FILE="$DOWNLOADS_DMG"
        echo HewlettPackardPrinterDrivers.dmg passed verification and the file is complete
            echo "HewlettPackardPrinterDrivers.dmg 通过校验，文件完整"
        echo ""
        else
            echo "HewlettPackardPrinterDrivers.dmg did not pass verification, the file is incomplete, and will start re-downloading from the apple cdn server"
            echo "HewlettPackardPrinterDrivers.dmg 未通过校验，文件不完整，开始从惠普 cdn 服务器重新下载"
            echo ""
            curl -L -o "$DEFAULT_DMG" "$URL"
	    if [ $? -ne 0 ]; then
    	        echo "Unable to connect to HP CDN server, download failed"
	        echo 无法连接到惠普 cdn 服务器，下载失败
	        echo ""
                exit 1
            fi
            DMG_FILE="$DEFAULT_DMG"
            echo "HewlettPackardPrinterDrivers.dmg download completed"
            echo "HewlettPackardPrinterDrivers.dmg 下载完成"
        echo ""
        fi

    elif [ -f "$DEFAULT_DMG" ]; then
        echo "HewlettPackardPrinterDrivers.dmg found in temp"
        echo "HewlettPackardPrinterDrivers.dmg 在临时目录中找到"
        echo ""
        echo "Checking file integrity by verifying hash value"
    echo "正在通过校验哈希值来检查文件该是否完整"
    echo ""
        if check_md5 "$DEFAULT_DMG"; then
            DMG_FILE="$DEFAULT_DMG"
            echo "HewlettPackardPrinterDrivers.dmg passed verification, the file is complete"
            echo "HewlettPackardPrinterDrivers.dmg 通过校验，文件完整"
        echo ""
        else
            echo "HewlettPackardPrinterDrivers.dmg did not pass verification, the file is incomplete, and will start re-downloading from the apple cdn server"
            echo "HewlettPackardPrinterDrivers.dmg 未通过校验，文件不完整，开始从惠普 cdn 服务器重新下载"
            echo ""
            curl -L -o "$DEFAULT_DMG" "$URL"
	    if [ $? -ne 0 ]; then
    	        echo "Unable to connect to HP CDN server, download failed"
	        echo 无法连接到惠普 cdn 服务器，下载失败
	        echo ""
                exit 1
            fi
            DMG_FILE="$DEFAULT_DMG"
        echo "HewlettPackardPrinterDrivers.dmg download completed"
            echo "HewlettPackardPrinterDrivers.dmg 下载完成"
        echo ""
        fi

    else
        echo "HewlettPackardPrinterDrivers.dmg not found, will start downloading from apple cdn server"
        echo "HewlettPackardPrinterDrivers.dmg 未找到，开始从惠普 cdn 服务器下载"
        echo ""
        curl -L -o "$DEFAULT_DMG" "$URL"
        if [ $? -ne 0 ]; then
    	    echo "Unable to connect to HP CDN server, download failed"
	    echo 无法连接到惠普 cdn 服务器，下载失败
	    echo ""
            exit 1
        fi
        DMG_FILE="$DEFAULT_DMG"
      echo "HewlettPackardPrinterDrivers.dmg download completed"
        echo "HewlettPackardPrinterDrivers.dmg 下载完成"
    echo ""
    fi

    echo "Mounting $DMG_FILE"
    echo "正在挂载 $DMG_FILE"
    echo ""

    MOUNT_POINT=$(hdiutil attach "$DMG_FILE" | grep "$VOLUME_NAME" | awk '{print $3}')
    echo "$MOUNT_POINT is mounted"
    echo "$MOUNT_POINT 已挂载"
    echo ""
fi


echo "(2/7)"
echo ""
echo "Extracting HewlettPackardPrinterDrivers.pkg"
echo "正在提取 HewlettPackardPrinterDrivers.pkg"
echo ""

PKG_FILE=$(find "$MOUNT_POINT" -name "HewlettPackardPrinterDrivers.pkg" | head -n 1)

xar -xf "$PKG_FILE" -C "$TEMP_DIR"
echo "HewlettPackardPrinterDrivers.pkg extraction completed"
echo "HewlettPackardPrinterDrivers.pkg 提取完成"
echo ""

hdiutil detach -force "/Volumes/HP_PrinterSupportManual" > /dev/null 2>&1
echo HP_PrinterSupportManual ejected
echo HP_PrinterSupportManual 已推出
echo ""

echo "(3/7)"
echo ""
echo "The payload file will be unpacked after 5 seconds"
echo "即将在5秒后解包 payload 文件"
sleep 5
echo ""

if [ -f "$TEMP_DIR/HewlettPackardPrinterDrivers.pkg/Payload" ]; then
    tar -xvf "$TEMP_DIR/HewlettPackardPrinterDrivers.pkg/Payload" -C "$TEMP_DIR"
else
    exit 1
fi

echo "payload file unpacking completed"
echo "payload 文件解包完成"
echo ""

echo "(4/7)"
echo ""
echo Copying the unpacked files to the specified directory
echo 正在将解包后的文件复制到指定目录
echo ""
echo Note: Click OK when the Legacy System Extension pop-up window pops up
echo 注意：弹出旧版系统扩展弹窗时点好
echo ""
sudo cp -R $TEMP_DIR/Library/* /Library/
sudo cp -R $TEMP_DIR/usr/libexec/* /usr/libexec/
echo The unpacked files have been copied to the specified directory
echo 解包后的文件已复制到指定目录
echo ""

echo "(5/7)"
echo "" 
echo Checking the CPU architecture type of this mac
echo 正在检查此 mac 的 CPU 架构类型
echo ""
 
ARCH=$(uname -m)

echo "$ARCH architecture"
echo "$ARCH 架构"
echo "" 

if [ "$ARCH" = "arm64" ]; then
    echo x86_64 programs need to be escaped before they can run
    echo x86_64 程序需转义后才可以运行
    echo ""
 
    echo Checking if Rosetta is installed
    echo 正在检查是否已安装 Rosetta
    echo ""
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        echo "Rosetta is already installed."
  	echo "Rosetta 已经安装"
    else
        echo "Rosetta is not installed, start downloading and installing from the Apple CDN server"
	echo "Rosetta 未安装，开始从 apple cdn 服务器下载并安装"
	echo ""
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
	echo ""

        if [ $? -eq 0 ]; then
            echo "Rosetta has been installed successfully"
	    echo "Rosetta 已安装成功"
 	    echo ""
        else
            echo "Rosetta installation failed"
	    echo "Rosetta 安装失败"
	    echo ""
        fi
    fi
elif [ "$ARCH" = "x86_64" ]; then
    echo x86_64 programs can be run directly without escaping
    echo x86_64 程序无需转义可直接运行
    echo ""  
else
    echo ""
fi

echo "(6/7)"
echo ""
echo Checking Gatekeeper status
echo 正在检查 Gatekeeper 状态
echo ""
status=$(spctl --status)
if [[ "$status" != *"disabled"* ]]; then
  echo Gatekeeper is in the enabled state, and is being disabled
  echo Gatekeeper 处于已启用状态，正在将其禁用
  echo ""
  sudo spctl --master-disable
  echo ""
  echo Gatekeeper is disabled.
  echo Gatekeeper 已禁用
  echo ""
  sudo open "x-apple.systempreferences:com.apple.preference.security"
  echo System settings have been opened, and automatically jumped to Privacy \& Security
  echo 系统设置已打开，并已自动跳转至隐私与安全性
  echo ""
  echo Please scroll to the security, and select Anywhere in Allow applications from
  echo 请滑到安全性，并在允许以下来源的应用程序里选择任何来源
  echo ""
  while true; do
    echo After making the selection, please enter ok below and press Enter
    echo 选择完毕后，请在下方输入 ok 并按回车
    echo ""
    read user_input
    if [ "$(echo "$user_input" | tr '[:upper:]' '[:lower:]')" == "ok" ]; then
        break
    fi
  done
  echo ""
else
  echo Gatekeeper is disabled
  echo Gatekeeper 已禁用
  echo ""
fi

echo "(7/7)"
echo ""
echo Cleaning up temporary files generated during installation
echo 正在清除安装过程中所产生的临时文件
echo ""
sudo rm -rf "TEMP_DIR"
echo Temporary files cleared
echo 临时文件已清除
echo "" 

echo "------------------------------"
echo ""

echo HP printer driver has been installed successfully
echo 惠普打印机驱动已安装成功
echo ""
echo This script has been fully executed, thank you for using
echo 此脚本已全部执行完毕，感谢使用
echo ""
exit 0



