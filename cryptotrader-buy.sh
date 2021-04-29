# Original for MAC Os: https://gist.github.com/svanas/652b765076a42a3f3d6ba0fe72592592 Written bij Stefan van As
# Adapted to linux by mauro33
# Example: 
# screen -S cryptotrader-buy
# ./cryptotrader-buy.sh --quote=USDT --exchange=X --price=X --api-key=X --api-secret=X --pushover-app-key=X --pushover-user-key=X --pushover-user-key=X --min24hsvolume=X --pairs=BTCUSDT,ETHUSDT,ADAUSDT

for i in "$@"
do
case $i in
    --quote=*)
    QUOTE="${i#*=}"
    shift   # past argument=value
    ;;
    --exchange=*)
    EXCHANGE="${i#*=}"
    shift   # past argument=value
    ;;
    --price=*)
    PRICE="${i#*=}"
    shift # past argument=value
    ;;
    --api-key=*)
    API_KEY="${i#*=}"
    shift # past argument=value
    ;;
    --api-secret=*)
    API_SECRET="${i#*=}"
    shift # past argument=value
    ;;
    --pushover-app-key=*)
    PUSHOVER_APP_KEY="${i#*=}"
    shift # past argument=value
    ;;
    --pushover-user-key=*)
    PUSHOVER_USER_KEY="${i#*=}"
    shift # past argument=value
    ;;
    --min24hsvolume=*)
    VOLUME="${i#*=}"
    shift # past argument=value
    ;;
	--pairs=*)
    PAIRS="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [ -z ${EXCHANGE+x} ]; then
    echo "missing argument: --exchange";
    exit 1
fi

if [ -z ${PRICE+x} ]; then
    echo "missing argument: --price";
    exit 1
fi

if [ -z ${API_KEY+x} ]; then
    echo "missing argument: --api-key";
    exit 1
fi

if [ -z ${API_SECRET+x} ]; then
    echo "missing argument: --api-secret";
    exit 1
fi

if [ -z ${PUSHOVER_APP_KEY+x} ]; then
    echo "missing argument: --pushover-app-key";
    exit 1
fi

if [ -z ${PUSHOVER_USER_KEY+x} ]; then
    echo "missing argument: --pushover-user-key";
    exit 1
fi

if [ -z ${PAIRS+x} ]; then
    ONLYPAIRS="false"
else
	ONLYPAIRS="true"	
fi

MARKETS=$(cryptotrader markets --exchange=$EXCHANGE)
if [ $? != 0 ]; then
    echo $MARKETS
    exit $?
fi

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get install -y jq;
fi

for MARKET in $(echo $MARKETS | jq -r '.[] | .name'); do
    ACTUAL_QUOTE=$(cryptotrader quote --exchange=$EXCHANGE --market=$MARKET)
	ACTUAL_BASE=$(cryptotrader base --exchange=$EXCHANGE --market=$MARKET)
	if [[ $ONLYPAIRS == "true" ]]; then
		if [[ $PAIRS =~ $MARKET ]]; then
			if [[ $ACTUAL_QUOTE == $QUOTE ]]; then
				cryptotrader buy --exchange=$EXCHANGE --market=$MARKET --api-key=$API_KEY --api-secret=$API_SECRET --api-passphrase=$PASS --telegram-app-key=none --pushover-app-key=$PUSHOVER_APP_KEY --pushover-user-key=$PUSHOVER_USER_KEY --price=$PRICE --volume=$VOLUME --dip=8 --repeat=1 --notify=3 --top=1 --dca &
			fi
		fi
	else
		if [[ $ONLYPAIRS == "false" ]]; then
			if [[ $ACTUAL_QUOTE == $QUOTE ]]; then
				cryptotrader buy --exchange=$EXCHANGE --market=$MARKET --api-key=$API_KEY --api-secret=$API_SECRET --api-passphrase=$PASS --telegram-app-key=none --pushover-app-key=$PUSHOVER_APP_KEY --pushover-user-key=$PUSHOVER_USER_KEY --price=$PRICE --volume=$VOLUME --dip=8 --repeat=1 --notify=3 --top=1 --dca &
			fi
		fi
	fi
done

echo Done

exit 0
