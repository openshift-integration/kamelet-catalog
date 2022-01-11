import com.consol.citrus.util.FileUtils
import org.apache.ftpserver.DataConnectionConfigurationFactory
import org.apache.ftpserver.listener.ListenerFactory

System.properties['citrus.ftp.marshaller.type'] = "JSON"

var userManagerProperties = FileUtils.getFileResource("classpath:ftp.server.properties")

ListenerFactory listenerFactory = new ListenerFactory();

DataConnectionConfigurationFactory connectionConfigurationFactory = new DataConnectionConfigurationFactory()
connectionConfigurationFactory.setPassivePorts("20022")
connectionConfigurationFactory.setPassiveExternalAddress("${ftp.server.host}.${YAKS_NAMESPACE}")

listenerFactory.setDataConnectionConfiguration(connectionConfigurationFactory.createDataConnectionConfiguration())

ftp()
  .server('ftp-server')
  .port(20021)
  .autoStart(true)
  .timeout(${ftp.server.timeout})
  .autoHandleCommands("${auto.handle.commands}")
  .userManagerProperties(userManagerProperties)
  .listenerFactory(listenerFactory)
