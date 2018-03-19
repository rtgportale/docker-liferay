#!/bin/bash

LIFERAY_HOME=/opt/liferay
CATALINA_HOME=$LIFERAY_HOME/tomcat
PROPS_FILE=$LIFERAY_HOME/portal-ext.properties

DB_KIND=${DB_KIND:-hypersonic}
DB_NAME=${DB_NAME:-lportal}
DB_HOST=${DB_HOST:-localhost}
if [ -n "$DB_PORT" ]; then
    DB_PORT=:$DB_PORT
fi

case "${DB_KIND,,}" in
  hypersonic)
    DB_DRIVER=org.hsqldb.jdbc.JDBCDriver
    DB_CONN_PARAMS=${DB_CONN_PARAMS:-hsqldb.write_delay=false}
    if [ -z "$DB_URL" ]; then
        DB_URL=jdbc:hsqldb:\$\{liferay.home\}/data/hypersonic/$DB_NAME;$DB_CONN_PARAMS
    fi
    DB_USERNAME=${DB_USERNAME:-sa}
    ;;
  mysql)
    DB_DRIVER=com.mysql.jdbc.Driver
    DB_CONN_PARAMS=${DB_CONN_PARAMS:-characterEncoding=UTF-8&dontTrackOpenResources=true&holdResultsOpenOverStatementClose=true&useFastDateParsing=false&useUnicode=true}
    if [ -z "$DB_URL" ]; then
        DB_URL=jdbc:mysql://$DB_HOST$DB_PORT/$DB_NAME?$DB_CONN_PARAMS
    fi
    ;;
  *)
    echo "Database kind '$DB_KIND' not supported!"
    exit 1
esac

SETUP_WIZARD_ENABLED=${SETUP_WIZARD_ENABLED:-false}
SCHEMA_RUN_ENABLED=${SCHEMA_RUN_ENABLED:-true}

cat > $PROPS_FILE << EOF
setup.wizard.enabled=$SETUP_WIZARD_ENABLED

jdbc.default.driverClassName=$DB_DRIVER
jdbc.default.url=$DB_URL
jdbc.default.username=$DB_USERNAME
jdbc.default.password=$DB_PASSWORD

schema.run.enabled=$SCHEMA_RUN_ENABLED
EOF

# start Tomcat
$CATALINA_HOME/bin/catalina.sh run
