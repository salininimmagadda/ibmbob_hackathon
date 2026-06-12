# MQ to SAP Integration - IBM ACE Project

## Overview
This IBM App Connect Enterprise (ACE) project provides a complete integration solution for reading messages from IBM MQ and sending them to SAP systems via HTTP/REST API. The solution includes comprehensive monitoring and error handling capabilities.

## Project Structure

```
MQtoSAP_Integration/
├── flows/
│   └── MQtoSAP_MainFlow.msgflow          # Main message flow
├── subflows/
│   ├── MonitoringEvent_IN.subflow        # Input monitoring subflow
│   ├── MonitoringEvent_OUT.subflow       # Output monitoring subflow
│   └── ErrorHandler.subflow              # Error handling subflow
├── esql/
│   ├── MonitoringEvent_IN_Compute.esql   # IN monitoring logic
│   ├── MonitoringEvent_OUT_Compute.esql  # OUT monitoring logic
│   ├── ErrorHandler_Compute.esql         # Error handling logic
│   ├── MQtoSAP_Transform.esql            # Message transformation
│   └── MQtoSAP_ProcessResponse.esql      # Response processing
└── README.md                              # This file
```

## Components

### 1. Main Flow (MQtoSAP_MainFlow.msgflow)
The main integration flow that orchestrates the entire process:
- **MQ Input Node**: Reads messages from `SAP.REQUEST.QUEUE`
- **Monitoring IN Subflow**: Creates monitoring event with status "IN"
- **Transform Node**: Transforms MQ message to SAP format
- **SAP HTTP Request Node**: Sends request to SAP system
- **Process Response Node**: Processes SAP response
- **Monitoring OUT Subflow**: Creates monitoring event with status "OUT"
- **Error Handler Subflow**: Handles all errors and writes to ETS queue

### 2. Subflow: MonitoringEvent_IN
**Purpose**: Create monitoring event after input node with status code "IN"

**Features**:
- Captures business unique ID from message
- Generates correlation ID
- Records timestamp and message metadata
- Stores monitoring data in Environment tree

**ESQL Module**: `MonitoringEvent_IN_Compute.esql`

### 3. Subflow: MonitoringEvent_OUT
**Purpose**: Create monitoring event after output node with status code "OUT"

**Features**:
- Updates monitoring event with status "OUT"
- Calculates processing duration
- Captures response information
- Determines success/failure status
- Logs final processing metrics

**ESQL Module**: `MonitoringEvent_OUT_Compute.esql`

### 4. Subflow: ErrorHandler
**Purpose**: Handle errors and write error messages to ETS queue

**Features**:
- Extracts all error details from ExceptionList
- Builds comprehensive error message structure
- Writes to `ETS.ERROR.QUEUE`
- Logs error information
- Includes original message payload (truncated if large)

**ESQL Modules**: 
- `ErrorHandler_Compute.esql` - Builds error message
- `ErrorHandler_LogError.esql` - Logs error details

### 5. Transform Module (MQtoSAP_Transform.esql)
**Purpose**: Transform MQ message to SAP format

**Features**:
- Converts message structure to SAP API format
- Adds SAP headers and authentication
- Supports Basic Auth and OAuth
- Configurable SAP endpoint
- Handles order data transformation (example)

### 6. Process Response Module (MQtoSAP_ProcessResponse.esql)
**Purpose**: Process SAP response and create standardized output

**Features**:
- Checks HTTP status codes
- Extracts SAP response data
- Handles success and error responses
- Creates standardized response structure
- Throws exceptions for error handling

## Configuration

### Environment Variables
Set these variables in your integration server or flow:

```bash
# SAP Configuration
SAP_ENDPOINT=https://sap-server.example.com/api/orders
SAP_USER=sapuser
SAP_PASS=sappassword
SAP_TOKEN=your_oauth_token  # If using OAuth

# MQ Configuration
MQ_QUEUE_MANAGER=QM1
INPUT_QUEUE=SAP.REQUEST.QUEUE
ERROR_QUEUE=ETS.ERROR.QUEUE
```

### Queue Setup
Create the following MQ queues:

```bash
# Input queue for SAP requests
DEFINE QLOCAL(SAP.REQUEST.QUEUE) MAXDEPTH(5000)

# Error queue for failed messages
DEFINE QLOCAL(ETS.ERROR.QUEUE) MAXDEPTH(10000)
```

## Message Format

### Input Message (MQ)
```json
{
  "order": {
    "orderNumber": "ORD-12345",
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
        },
        {
          "productId": "PROD-002",
          "quantity": 1,
          "unitPrice": 500.00,
          "uom": "EA"
        }
      ]
    }
  }
}
```

### SAP Request Format
```json
{
  "SAPHeader": {
    "MessageType": "ORDER_CREATE",
    "Timestamp": "2026-06-11T13:00:00.000Z",
    "SourceSystem": "MQ_INTEGRATION",
    "TargetSystem": "SAP_ERP",
    "TransactionId": "TXN-12345"
  },
  "Order": {
    "OrderNumber": "ORD-12345",
    "OrderDate": "2026-06-11",
    "CustomerNumber": "CUST-001",
    "TotalAmount": 1500.00,
    "Currency": "USD",
    "Items": [
      {
        "ItemNumber": 1,
        "MaterialNumber": "PROD-001",
        "Quantity": 2,
        "UnitPrice": 500.00,
        "TotalPrice": 1000.00,
        "UnitOfMeasure": "EA"
      }
    ]
  }
}
```

### Success Response
```json
{
  "ResponseHeader": {
    "Timestamp": "2026-06-11T13:00:01.000Z",
    "HTTPStatusCode": 200,
    "SourceSystem": "SAP_ERP",
    "TransactionId": "TXN-12345",
    "CorrelationId": "CORR-12345"
  },
  "Status": "SUCCESS",
  "Message": "SAP request processed successfully",
  "SAPResponse": {
    "OrderNumber": "ORD-12345",
    "DocumentNumber": "SAP-DOC-98765",
    "Status": "CREATED"
  },
  "ProcessingInfo": {
    "FlowName": "MQtoSAP_MainFlow",
    "ProcessedAt": "2026-06-11T13:00:01.000Z",
    "DurationMs": 1250
  }
}
```

### Error Message (ETS Queue)
```json
{
  "ErrorHeader": {
    "Timestamp": "2026-06-11T13:00:01.000Z",
    "FlowName": "MQtoSAP_MainFlow",
    "NodeName": "ErrorHandler",
    "BusinessUniqueId": "ORD-12345",
    "CorrelationId": "CORR-12345",
    "MessageId": "414D51..."
  },
  "ErrorDetails": [
    {
      "ErrorNumber": 1,
      "ErrorType": "HTTPRequestError",
      "ErrorCode": "2951",
      "ErrorText": "SAP request failed",
      "ErrorInserts": "SERVER_ERROR | SAP server error",
      "Catalog": "BIPmsgs",
      "Severity": "3"
    }
  ],
  "ErrorSummary": {
    "TotalErrors": 1,
    "Severity": "ERROR",
    "Status": "FAILED"
  },
  "OriginalMessage": "{ original message content... }"
}
```

## Monitoring Events

### IN Event Structure
```
Environment.MonitoringEvent:
  - StatusCode: "IN"
  - BusinessUniqueId: "ORD-12345"
  - CorrelationId: "CORR-12345"
  - Timestamp: 2026-06-11T13:00:00.000Z
  - FlowName: "MQtoSAP_MainFlow"
  - NodeName: "MonitoringEvent_IN"
  - MessageId: "414D51..."
  - SourceQueue: "SAP.REQUEST.QUEUE"
  - MessageFormat: "JSON"
  - MessageSize: 1024
```

### OUT Event Structure
```
Environment.MonitoringEvent:
  - StatusCode: "OUT"
  - BusinessUniqueId: "ORD-12345"
  - CorrelationId: "CORR-12345"
  - OutTimestamp: 2026-06-11T13:00:01.000Z
  - ProcessingDurationMs: 1250
  - FlowName: "MQtoSAP_MainFlow"
  - NodeName: "MonitoringEvent_OUT"
  - ResponseType: "HTTP"
  - HTTPStatusCode: 200
  - ResponseSize: 512
  - Success: true
  - Status: "SUCCESS"
```

## Deployment

### 1. Import Project to ACE Toolkit
```bash
# Open ACE Toolkit
# File > Import > Project Interchange
# Select the project directory
```

### 2. Create BAR File
```bash
mqsicreatebar -data /path/to/workspace -b MQtoSAP.bar -a MQtoSAP_Integration
```

### 3. Deploy to Integration Server
```bash
mqsideploy <integration_node> -e <integration_server> -a MQtoSAP.bar
```

### 4. Set Configurable Properties (Optional)
```bash
# Set SAP endpoint
mqsichangeproperties <node> -e <server> -o ComIbmHTTPRequest -n URL \
  -v "https://your-sap-server.com/api/orders"
```

## Testing

### 1. Send Test Message to MQ
```bash
# Using amqsput
echo '{"order":{"orderNumber":"TEST-001","customerId":"CUST-001"}}' | \
  amqsput SAP.REQUEST.QUEUE QM1
```

### 2. Monitor Flow Execution
```bash
# Check integration server logs
tail -f /var/mqsi/components/<node>/servers/<server>/logs/console.log

# Check user trace
mqsireadlog <node> -e <server> -u
```

### 3. Verify Error Handling
```bash
# Check ETS error queue
amqsbcg ETS.ERROR.QUEUE QM1
```

## Troubleshooting

### Common Issues

1. **Connection to SAP fails**
   - Check SAP endpoint URL
   - Verify authentication credentials
   - Check network connectivity and firewall rules

2. **Messages stuck in input queue**
   - Check integration server status
   - Verify queue permissions
   - Check for parsing errors in logs

3. **Errors not appearing in ETS queue**
   - Verify ETS.ERROR.QUEUE exists
   - Check queue permissions
   - Review error handler subflow connections

4. **High memory usage**
   - Review message sizes
   - Check for memory leaks in ESQL
   - Adjust JVM heap settings

### Debug Commands
```bash
# Check flow status
mqsireportproperties <node> -e <server> -o ComIbmMessageFlow -r

# Enable user trace
mqsichangetrace <node> -n on -t 4 -e <server>

# View statistics
mqsireportflowmonitoring <node> -e <server> -f MQtoSAP_MainFlow
```

## Best Practices

1. **Always close database connections** in ESQL
2. **Clear large message trees** when no longer needed
3. **Implement proper error handling** for all nodes
4. **Use correlation IDs** for message tracking
5. **Monitor memory usage** regularly
6. **Test with production-like data volumes**
7. **Document SAP API requirements** clearly
8. **Use configurable properties** for environment-specific values

## Customization

### Modify SAP Transformation
Edit `esql/MQtoSAP_Transform.esql` to match your SAP API requirements:
- Update field mappings
- Add/remove SAP headers
- Modify authentication method
- Change data structures

### Add Additional Monitoring
Extend monitoring events in:
- `esql/MonitoringEvent_IN_Compute.esql`
- `esql/MonitoringEvent_OUT_Compute.esql`

### Customize Error Handling
Modify `esql/ErrorHandler_Compute.esql` to:
- Add custom error codes
- Change error message format
- Add additional error routing logic

## Support

For issues or questions:
1. Check ACE documentation: https://www.ibm.com/docs/en/app-connect
2. Review IBM Support: https://www.ibm.com/support
3. Contact your ACE administrator

## Version History

- **v1.0** (2026-06-11): Initial release
  - MQ to SAP integration
  - Monitoring events (IN/OUT)
  - Error handling with ETS queue
  - Complete ESQL modules

## License

This project is provided as-is for use with IBM App Connect Enterprise.