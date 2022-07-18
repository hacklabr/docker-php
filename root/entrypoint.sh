#!/bin/bash
if [ -n "$XDEBUG" ];
then
    inifile="/usr/local/etc/php/conf.d/pecl-xdebug.ini"
    extfile="$(find /usr/local/lib/php/extensions/ -name xdebug.so)";
    remote_port="${XDEBUG_REMOTE_PORT:-9000}";
    idekey="${XDEBUG_IDEKEY:-xdbg}";

    if [ -f "$extfile" ] && [ ! -f "$inifile" ];
    then
        {
            echo "[Xdebug]";
            echo "zend_extension=${extfile}";
            echo "xdebug.idekey=${idekey}";
            echo "xdebug.remote_enable=1";
            echo "xdebug.remote_connect_back=1";
            echo "xdebug.remote_autostart=1";
            echo "xdebug.remote_port=${remote_port}";
        } > $inifile;
    fi

    unset extfile remote_port idekey;
fi

# Set user Password
if [[ ! -z $ROOT_PASSWORD ]]; then

  $(echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root )

fi


# Check if username and password are set, if is check for alternative user folder.
if [[ ! -z $USER_NAME ]] && [[ ! -z  $USER_PASSWORD ]]; then
  
  if [[ ! -z $USER_FOLDER ]]; then

    $(mkdir -p $USER_FOLDER)
    $(useradd $USER_NAME -d $USER_FOLDER --shell /bin/bash)
    $(echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME )

  else

    $(useradd $USER_NAME -d $USER_FOLDER --shell /bin/bash)
    $(echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME )

  fi
fi  
service ssh start
exec "$@"
