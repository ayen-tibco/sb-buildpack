ADMINISTRATOR=$TIBCO_EP_HOME/distrib/tibco/bin/epadministrator
NODE_INSTALL_PATH=$HOME/deploy/nodes
export _JAVA_OPTIONS=-DTIBCO_EP_HOME=$TIBCO_EP_HOME
DOMAIN_NAME=`domainname -d`

# check if Cluster is present
if [ ! -z "$1" ]; then
  ClusterName=$1
else
  DOMAIN_NAME=`domainname -d`
  if [ ! -z "$DOMAIN_NAME" ]; then
    ClusterName=$DOMAIN_NAME
  else
    ClusterName=Cluster1
  fi
fi


# if node config is present, ignore nodename parameter
if [ ! -z "$NODE_CONFIG" ]; then
        NODE_CONFIG="nodedeploy=$SB_APP_DIR/$NODE_CONFIG"
fi

# check if nodename is present
if [ ! -z "$NODENAME" ]; then
    NODE_NAME="nodename=$NODENAME"
else
  if [ -z "$DOMAIN_NAME" ]; then
    NODENAME=$HOSTNAME.$ClusterName
  else
    NODENAME=$HOSTNAME
  fi
    NODE_NAME="nodename=$NODENAME"
fi

if [ ! -z "$SB_APP_FRAGMENT" ]; then
    SB_APP_FRAGMENT="application=$SB_APP_DIR/$SB_APP_FRAGMENT"
fi

if [ ! -z "$SUBSTITUTIONS" ]; then
    SUBSTITUTIONS=substitutions="$SUBSTITUTIONS"
fi

if [ ! -z "$2" ]; then
  APPLIB_PATH=$2
else
  APPLIB_PATH=$STREAMBASE_HOME/lib
fi

if [ ! -d "$NODE_INSTALL_PATH" ]; then
        mkdir -p $NODE_INSTALL_PATH
fi

# Install node A in cluster X - administration port set to 5556
$ADMINISTRATOR install node $DISCOVERYHOSTS nodedirectory=$NODE_INSTALL_PATH adminport=5556 $NODE_NAME $SB_APP_FRAGMENT $NODE_CONFIG $SUBSTITUTIONS deploydirectories=$APPLIB_PATH:$SB_APP_DIR:$SB_APP_DIR/java-bin buildtype=DEVELOPMENT
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo "Failed INSTALLING node, error code is ${exit_code}. Shutting down container..."
    exit $exit_code
else
    #Start the node using the assigned administration port
    $ADMINISTRATOR adminport=5556 start node
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "Node started successfully."
        exit 0
    else
        echo "Failed STARTING node, error code is ${exit_code}. Shutting down container..."
        exit $exit_code
    fi
fi

