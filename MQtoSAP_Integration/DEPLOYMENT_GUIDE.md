# MQ to SAP Integration - Deployment Guide

## Prerequisites

### Software Requirements
- IBM App Connect Enterprise v11.0 or higher
- IBM MQ v9.0 or higher
- Access to SAP system with REST API
- ACE Toolkit (for development)

### Access Requirements
- ACE Integration Node administrator access
- MQ Queue Manager administrator access
- SAP API credentials (username/password or OAuth token)
- Network access to SAP endpoints

## Step-by-Step Deployment

### Step 1: Prepare MQ Environment

#### 1.1 Create Queue Manager (if not exists)
```bash
# Create queue manager
crtmqm QM1

# Start queue manager
strmqm QM1
```

#### 1.2 Create Required Queues
```bash
# Connect to queue manager
runmqsc QM1

# Create input queue
DEFINE QLOCAL(SAP.REQUEST.QUEUE) +
  MAXDEPTH(5000) +
  DEFPSIST(YES) +
  DESCR('Input queue for SAP requests')

# Create error queue
DEFINE QLOCAL(ETS.ERROR.QUEUE) +
  MAXDEPTH(10000) +
  DEFPSIST(YES) +
  DESCR('Error queue for failed messages')

# Create backout queue (optional)
DEFINE QLOCAL(SAP.BACKOUT.QUEUE) +
  MAXDEPTH(5000) +
  DEFPSIST(YES) +
  DESCR('Backout queue for retry failures')

# Exit runmqsc
END
```

#### 1.3 Configure Queue Manager for ACE
```bash
# Set authority for ACE user
setmqaut -m QM1 -t qmgr -p aceuser +connect +inq
setmqaut -m QM1 -t queue -n SAP.REQUEST.QUEUE -p aceuser +put +get +browse +inq
setmqaut -m QM1 -t queue -n ETS.ERROR.QUEUE -p aceuser +put +get +browse +inq
```

### Step 2: Prepare ACE Environment

#### 2.1 Create Integration Node (if not exists)
```bash
# Create integration node
mqsicreatebroker NODE1 -q QM1

# Start integration node
mqsistart NODE1
```

#### 2.2 Create Integration Server
```bash
# Create integration server
mqsicreateexecutiongroup NODE1 -e SERVER1

# Verify creation
mqsilist NODE1
```

#### 2.3 Configure Integration Server
```bash
# Set JVM heap size (adjust based on load)
mqsichangeproperties NODE1 -e SERVER1 -o ComIbmJVMManager -n jvmMaxHeapSize -v 512

# Enable resource statistics
mqsichangeresourcestats NODE1 -e SERVER1 -c active

# Set timezone (if needed)
mqsichangeproperties NODE1 -e SERVER1 -o ComIbmJVMManager -n jvmSystemProperty -v "-Duser.timezone=UTC"
```

### Step 3: Import and Build Project

#### 3.1 Import Project to ACE Toolkit
1. Open IBM App Connect Toolkit
2. Select workspace directory
3. File → Import → Project Interchange
4. Browse to `MQtoSAP_Integration` directory
5. Select all files and click Finish

#### 3.2 Verify Project Structure
Ensure all files are imported:
- ✓ flows/MQtoSAP_MainFlow.msgflow
- ✓ subflows/MonitoringEvent_IN.subflow
- ✓ subflows/MonitoringEvent_OUT.subflow
- ✓ subflows/ErrorHandler.subflow
- ✓ esql/*.esql (all ESQL files)

#### 3.3 Create BAR File
```bash
# Using command line
mqsicreatebar -data /path/to/workspace \
  -b MQtoSAP_Integration.bar \
  -a MQtoSAP_Integration \
  -deployAsSource

# Or use ACE Toolkit:
# File → New → BAR file
# Add MQtoSAP_Integration project
# Build and Save
```

### Step 4: Configure Security

#### 4.1 Set SAP Credentials
```bash
# Option 1: Basic Authentication
mqsisetdbparms NODE1 -n sap::credentials -u sapuser -p sappassword

# Option 2: OAuth Token
mqsisetdbparms NODE1 -n sap::token -u token -p your_oauth_token_here
```

#### 4.2 Configure SSL/TLS (if SAP uses HTTPS)
```bash
# Create truststore with SAP certificate
keytool -import -alias sap-cert \
  -file sap-server.crt \
  -keystore /path/to/truststore.jks \
  -storepass password

# Set truststore for integration server
mqsichangeproperties NODE1 -e SERVER1 \
  -o BrokerRegistry -n brokerTruststoreFile \
  -v /path/to/truststore.jks

mqsichangeproperties NODE1 -e SERVER1 \
  -o BrokerRegistry -n brokerTruststorePass \
  -v password
```

### Step 5: Deploy BAR File

#### 5.1 Deploy to Integration Server
```bash
# Deploy BAR file
mqsideploy NODE1 -e SERVER1 -a MQtoSAP_Integration.bar -w 120

# Verify deployment
mqsilist NODE1 -e SERVER1 -d 2
```

#### 5.2 Check Deployment Status
```bash
# Check if flow is running
mqsireportproperties NODE1 -e SERVER1 -o ComIbmMessageFlow -r

# Expected output should show:
# MQtoSAP_MainFlow - running
```

### Step 6: Configure Runtime Properties

#### 6.1 Set SAP Endpoint
```bash
# Set SAP endpoint URL
mqsichangeproperties NODE1 -e SERVER1 \
  -o ComIbmHTTPRequest -n URL \
  -v "https://your-sap-server.com/api/orders"
```

#### 6.2 Configure HTTP Timeout
```bash
# Set HTTP request timeout (in seconds)
mqsichangeproperties NODE1 -e SERVER1 \
  -o ComIbmHTTPRequest -n httpTimeout -v 60
```

#### 6.3 Set Environment Variables (Optional)
Create a properties file: `MQtoSAP.properties`
```properties
# SAP Configuration
SAP_ENDPOINT=https://your-sap-server.com/api/orders
SAP_USER=sapuser
SAP_PASS=sappassword
SAP_CLIENT=100

# MQ Configuration
INPUT_QUEUE=SAP.REQUEST.QUEUE
ERROR_QUEUE=ETS.ERROR.QUEUE
```

Apply properties:
```bash
mqsiapplybaroverride -b MQtoSAP_Integration.bar \
  -p MQtoSAP.properties \
  -o MQtoSAP_Configured.bar

mqsideploy NODE1 -e SERVER1 -a MQtoSAP_Configured.bar -w 120
```

### Step 7: Enable Monitoring

#### 7.1 Enable Flow Monitoring
```bash
# Enable monitoring for the flow
mqsichangeflowmonitoring NODE1 -e SERVER1 \
  -f MQtoSAP_MainFlow -c active

# Enable statistics
mqsichangeflowstats NODE1 -e SERVER1 \
  -f MQtoSAP_MainFlow -c active -s -j -n -t
```

#### 7.2 Configure User Trace (for debugging)
```bash
# Enable user trace
mqsichangetrace NODE1 -n on -t 4 -e SERVER1

# View trace
mqsireadlog NODE1 -e SERVER1 -u
```

### Step 8: Testing

#### 8.1 Send Test Message
```bash
# Create test message file: test_message.json
cat > test_message.json << 'EOF'
{
  "order": {
    "orderNumber": "TEST-001",
    "orderDate": "2026-06-11",
    "customerId": "CUST-001",
    "totalAmount": 1500.00,
    "currency": "USD",
    "items": {
      "item": [
        {
          "productId": "PROD-001",
          "quantity": 2,
          "unitPrice": 500.00,
          "uom": "EA"
        }
      ]
    }
  }
}
EOF

# Send to MQ queue
cat test_message.json | amqsput SAP.REQUEST.QUEUE QM1
```

#### 8.2 Monitor Processing
```bash
# Watch integration server logs
tail -f /var/mqsi/components/NODE1/servers/SERVER1/logs/console.log

# Check for monitoring events
grep "MONITORING" /var/mqsi/components/NODE1/servers/SERVER1/logs/console.log
```

#### 8.3 Verify Success
```bash
# Check if message was processed (queue should be empty)
echo "DISPLAY QLOCAL(SAP.REQUEST.QUEUE) CURDEPTH" | runmqsc QM1

# Check error queue (should be empty for success)
echo "DISPLAY QLOCAL(ETS.ERROR.QUEUE) CURDEPTH" | runmqsc QM1
```

#### 8.4 Test Error Handling
```bash
# Send invalid message to test error handling
echo '{"invalid": "data"}' | amqsput SAP.REQUEST.QUEUE QM1

# Check error queue
amqsbcg ETS.ERROR.QUEUE QM1
```

### Step 9: Production Readiness

#### 9.1 Performance Tuning
```bash
# Increase additional instances for parallel processing
mqsichangeproperties NODE1 -e SERVER1 \
  -o ExecutionGroup -n additionalInstances -v 3

# Adjust thread pool
mqsichangeproperties NODE1 -e SERVER1 \
  -o ExecutionGroup -n threadPoolSize -v 10
```

#### 9.2 Configure High Availability (Optional)
```bash
# Create multi-instance queue manager
crtmqm -md /shared/qmdata -ld /shared/qmlogs QM1_HA

# Configure integration node for HA
mqsicreatebroker NODE1_HA -q QM1_HA -i /shared/acedata
```

#### 9.3 Set Up Monitoring Alerts
Create monitoring script: `monitor_flow.sh`
```bash
#!/bin/bash
# Monitor flow health

NODE="NODE1"
SERVER="SERVER1"
FLOW="MQtoSAP_MainFlow"

# Check flow status
STATUS=$(mqsireportproperties $NODE -e $SERVER -o ComIbmMessageFlow -n $FLOW -r | grep "running")

if [ -z "$STATUS" ]; then
    echo "ALERT: Flow $FLOW is not running!"
    # Send alert (email, SMS, etc.)
fi

# Check error queue depth
DEPTH=$(echo "DISPLAY QLOCAL(ETS.ERROR.QUEUE) CURDEPTH" | runmqsc QM1 | grep CURDEPTH | awk '{print $2}')

if [ "$DEPTH" -gt 100 ]; then
    echo "ALERT: Error queue depth is $DEPTH"
    # Send alert
fi
```

#### 9.4 Schedule Regular Maintenance
```bash
# Add to crontab
crontab -e

# Monitor every 5 minutes
*/5 * * * * /path/to/monitor_flow.sh

# Clean old logs daily
0 2 * * * find /var/mqsi/components/NODE1/servers/SERVER1/logs -name "*.log" -mtime +7 -delete
```

### Step 10: Backup and Recovery

#### 10.1 Backup Configuration
```bash
# Backup BAR file
cp MQtoSAP_Integration.bar /backup/ace/MQtoSAP_Integration_$(date +%Y%m%d).bar

# Backup integration node configuration
mqsibackupbroker NODE1 -d /backup/ace/NODE1_$(date +%Y%m%d)

# Backup queue manager
dmpmqcfg -m QM1 > /backup/mq/QM1_config_$(date +%Y%m%d).mqsc
```

#### 10.2 Recovery Procedure
```bash
# Restore integration node
mqsirestorebroker NODE1 -d /backup/ace/NODE1_20260611

# Redeploy BAR file
mqsideploy NODE1 -e SERVER1 -a /backup/ace/MQtoSAP_Integration_20260611.bar

# Restore queue manager configuration
runmqsc QM1 < /backup/mq/QM1_config_20260611.mqsc
```

## Troubleshooting

### Issue: Flow not starting
```bash
# Check integration server status
mqsireportproperties NODE1 -e SERVER1 -o ExecutionGroup -r

# Check for errors in logs
tail -100 /var/mqsi/components/NODE1/servers/SERVER1/logs/console.log

# Restart integration server
mqsistop NODE1 -e SERVER1
mqsistart NODE1 -e SERVER1
```

### Issue: Cannot connect to SAP
```bash
# Test connectivity
curl -v https://your-sap-server.com/api/orders

# Check SSL certificates
openssl s_client -connect your-sap-server.com:443

# Verify credentials
mqsireportproperties NODE1 -c AllReportableEntityNames
```

### Issue: Messages stuck in queue
```bash
# Check queue status
echo "DISPLAY QLOCAL(SAP.REQUEST.QUEUE) ALL" | runmqsc QM1

# Check if flow is consuming
mqsireportflowmonitoring NODE1 -e SERVER1 -f MQtoSAP_MainFlow

# Enable trace for debugging
mqsichangetrace NODE1 -n on -t 4 -e SERVER1
```

## Post-Deployment Checklist

- [ ] All queues created and configured
- [ ] Integration node and server running
- [ ] BAR file deployed successfully
- [ ] SAP credentials configured
- [ ] SSL/TLS certificates installed (if needed)
- [ ] Test message processed successfully
- [ ] Error handling verified
- [ ] Monitoring enabled
- [ ] Alerts configured
- [ ] Backup procedures in place
- [ ] Documentation updated
- [ ] Team trained on operations

## Support Contacts

- **ACE Administrator**: [contact info]
- **MQ Administrator**: [contact info]
- **SAP Team**: [contact info]
- **Network Team**: [contact info]

## Additional Resources

- IBM ACE Documentation: https://www.ibm.com/docs/en/app-connect
- IBM MQ Documentation: https://www.ibm.com/docs/en/ibm-mq
- Project README: See README.md in project root