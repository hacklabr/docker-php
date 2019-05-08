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

# Configuring Sendmail

if [ ! -z $SMTP_HOST ]; then
  sendmail_ini="/usr/local/etc/php/conf.d/sendmail.ini"
  {
  echo "[mail function]
  SMTP = $SMTP_HOST
  smtp_port = $SMTP_PORT
  username = $SMTP_USER
  password = $SMTP_PASSWORD
  sendmail_path= /usr/sbin/sendmail"
  } >  $sendmail_ini

  sed -i s'/SMTP_PASSWORD/'$SMTP_PASSWORD'/' /etc/mail/authinfo/user-auth
  sed -i s'/SMTP_USER/'$SMTP_USER'/' /etc/mail/authinfo/user-auth
  sed -i s'/smtp.mail.com/'$SMTP_HOST'/' /etc/mail/sendmail.mc
  sed -i s'/587/'$SMTP_PORT'/' /etc/mail/sendmail.mc

  makemap hash /etc/mail/authinfo/user-auth < /etc/mail/authinfo/user-auth
  make -C /etc/mail

fi

exec "$@"
