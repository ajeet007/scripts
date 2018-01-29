SRV_NAME=Jenkins
SRV_HOME=$HOME/jenkins
SRV_JAVA_HOME=/opt/java/jdk1.8.0_144
SRV_JAVA_OPTS="--httpPort=8080"
SRV_JAVA_OPTS="$SRV_JAVA_OPTS --prefix=/jenkins"
SRV_WAR=$SRV_HOME/jenkins.war
SRV_PIDPATH=$SRV_HOME/bin
SRV_LOG_PATH=$SRV_HOME/logs
export JENKINS_HOME=/data/jenkins

if [ ! -n "$JAVA_HOME" ]; then
  SRV_JAVA_HOME=$JAVA_HOME
fi

if [ ! -d $SRV_LOG_PATH ]; then
  mkdir -p $SRV_LOG_PATH
fi

if [ ! -d $SRV_PIDPATH ]; then
  mkdir -p $SRV_PIDPATH
fi

is_process_running(){
  IS_RUNNING=false
  if [ -f $SRV_PIDPATH/${SRV_NAME}_pid ]; then
    pid=`cat $SRV_PIDPATH/${SRV_NAME}_pid`
    if [ -n "`ps -ef|grep $pid|grep -v grep`" ]; then
      IS_RUNNING="true"
    fi
  fi
}


start_serv(){
  echo "Starting $SRV_NAME server... "
  nohup $SRV_JAVA_HOME/bin/java -jar $SRV_WAR $SRV_JAVA_OPTS > $SRV_LOG_PATH/${SRV_NAME}.stdout 2>&1 &
  echo $! > $SRV_PIDPATH/${SRV_NAME}_pid
  sleep 1
  is_process_running
  if [ "$IS_RUNNING" = true ]; then
    echo "started"
  else
    echo "Start fail, please check $SRV_LOG_PATH/${SRV_NAME}.stdout"
  fi
}

stop_serv(){
  if [ -f $SRV_PIDPATH/${SRV_NAME}_pid ]; then
    pid=`cat $SRV_PIDPATH/${SRV_NAME}_pid`
    is_process_running
    if [ "$IS_RUNNING" = true ]; then
      kill -9 $pid
      echo "$SRV_NAME server is stopped"
    else
      echo "$SRV_NAME server is gone"
    fi
    rm -f $SRV_PIDPATH/${SRV_NAME}_pid
  else
    echo "$SRV_NAME server is not running"
  fi
}

status_serv(){
  if [ -f $SRV_PIDPATH/${SRV_NAME}_pid ]; then
    pid=`cat $SRV_PIDPATH/${SRV_NAME}_pid`
    is_process_running
    if [ "$IS_RUNNING" = true ]; then
      echo "$SRV_NAME server is running"
    else
      echo "$SRV_NAME server is gone"
    fi
  else
    echo "$SRV_NAME server is not running"
  fi
}

usage(){
  echo $"Usage: $0 {start|stop|status|restart}"
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

case "$1" in
  start)
    start_serv
    ;;
  stop)
    stop_serv
    ;;
  status)
    status_serv
    ;;
  restart)
    stop_serv
    sleep 2
    start_serv
    ;;
  *)
    usage
    exit 1
esac

