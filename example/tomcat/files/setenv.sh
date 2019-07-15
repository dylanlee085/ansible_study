#add tomcat pid
CATALINA_PID="$CATALINA_BASE/tomcat.pid"
#add java opts
JAVA_OPTS="-server -XX:MetaspaceSize=256M -XX:MaxMetaspaceSize=1024m -Xms512M -Xmx1024M -XX:MaxNewSize=256m"
