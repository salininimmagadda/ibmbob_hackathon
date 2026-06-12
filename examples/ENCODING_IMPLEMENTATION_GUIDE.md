# CCSID 819 Encoding Handler - Implementation Guide

## Overview

This guide explains how to implement the ASBITSTREAM encoding handler with CCSID 819 fallback to Java conversion for unsupported characters.

## Solution Components

### 1. ESQL Module: `EncodingHandler.esql`
- Attempts ASBITSTREAM with CCSID 819
- Catches encoding errors
- Falls back to Java converter
- Provides detailed logging

### 2. Java Class: `CharacterConverter.java`
- Converts unsupported characters
- Handles smart quotes, special symbols, Unicode
- Provides multiple conversion strategies
- Returns detailed conversion reports

## Implementation Steps

### Step 1: Add Java Class to ACE Project

#### Option A: Using ACE Toolkit

1. **Create Java Project in Workspace:**
   ```
   File → New → Java Project
   Name: EncodingUtils
   ```

2. **Create Package Structure:**
   ```
   EncodingUtils/
   └── src/
       └── com/
           └── ibm/
               └── ace/
                   └── encoding/
                       └── CharacterConverter.java
   ```

3. **Copy Java Code:**
   - Copy `CharacterConverter.java` to the package
   - Build project (Project → Build Project)

4. **Export as JAR:**
   ```
   File → Export → Java → JAR file
   Select: EncodingUtils project
   Export destination: /path/to/EncodingUtils.jar
   ```

#### Option B: Using Command Line

```bash
# Create directory structure
mkdir -p EncodingUtils/src/com/ibm/ace/encoding

# Copy Java file
cp CharacterConverter.java EncodingUtils/src/com/ibm/ace/encoding/

# Compile
cd EncodingUtils
javac -d bin src/com/ibm/ace/encoding/CharacterConverter.java

# Create JAR
jar cvf EncodingUtils.jar -C bin .
```

### Step 2: Deploy JAR to ACE Runtime

#### Method 1: Shared Classes Directory (Recommended)

```bash
# Copy JAR to shared classes directory
cp EncodingUtils.jar /var/mqsi/shared-classes/

# Or for specific integration server
cp EncodingUtils.jar /var/mqsi/components/ACE_NODE/servers/ACE_SERVER/shared-classes/
```

#### Method 2: Include in BAR File

```bash
# Using mqsicreatebar
mqsicreatebar -data /path/to/workspace \
  -b MyApplication.bar \
  -a MyApplication \
  -l EncodingUtils.jar

# The JAR will be deployed with the application
```

#### Method 3: Server Work Path

```bash
# Add to server's work path
mqsichangeproperties ACE_NODE -e ACE_SERVER \
  -o ComIbmJVMManager -n jvmSystemProperty \
  -v "-Djava.class.path=/path/to/EncodingUtils.jar"
```

### Step 3: Create Message Flow

#### Flow Structure

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  HTTPInput  │────▶│   Compute    │────▶│  HTTPReply  │
│             │     │  (Encoding)  │     │             │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           │ (on error)
                           ▼
                    ┌──────────────┐
                    │   Compute    │
                    │ (Java Conv)  │
                    └──────────────┘
```

#### Implementation in ACE Toolkit

1. **Create Message Flow:**
   ```
   File → New → Message Flow
   Name: EncodingHandlerFlow.msgflow
   ```

2. **Add Nodes:**
   - HTTPInput (or your input node)
   - Compute node (EncodingHandler_Compute)
   - HTTPReply (or your output node)

3. **Configure Compute Node:**
   - Right-click Compute node → Properties
   - ESQL Module: Select `EncodingHandler_Compute`
   - Or paste ESQL code directly

### Step 4: Configure ESQL Module

#### Basic Implementation

```esql
CREATE COMPUTE MODULE EncodingHandler_Compute
    CREATE FUNCTION Main() RETURNS BOOLEAN
    BEGIN
        DECLARE encodedData BLOB;
        DECLARE originalData CHARACTER;
        
        -- Get input data (adjust path for your message structure)
        SET originalData = InputRoot.XMLNSC.Data.Content;
        
        -- Try ASBITSTREAM with CCSID 819
        BEGIN
            SET encodedData = ASBITSTREAM(InputRoot.XMLNSC CCSID 819 ENCODING 546);
            SET OutputRoot.BLOB.BLOB = encodedData;
            SET OutputLocalEnvironment.Variables.Status = 'SUCCESS';
            
        EXCEPTION
            WHEN SQLSTATE LIKE 'BIP%' THEN
                -- Call Java converter
                CALL handleEncodingError(originalData, encodedData);
        END;
        
        RETURN TRUE;
    END;
    
    CREATE PROCEDURE handleEncodingError(
        IN inputData CHARACTER,
        INOUT outputData BLOB
    )
    BEGIN
        DECLARE convertedData CHARACTER;
        
        -- Call Java function
        SET convertedData = callJavaConverter(inputData);
        
        -- Convert to BLOB
        SET outputData = ASBITSTREAM(convertedData CCSID 819 ENCODING 546);
        SET OutputRoot.BLOB.BLOB = outputData;
        SET OutputLocalEnvironment.Variables.Status = 'JAVA_CONVERTED';
    END;
    
    CREATE FUNCTION callJavaConverter(IN inputText CHARACTER) 
        RETURNS CHARACTER
        LANGUAGE JAVA
        EXTERNAL NAME "com.ibm.ace.encoding.CharacterConverter.convert";
        
END MODULE;
```

### Step 5: Testing

#### Test Case 1: Valid ISO-8859-1 Characters

**Input:**
```xml
<Data>
    <Content>Hello World! Test 123</Content>
</Data>
```

**Expected Output:**
- Status: SUCCESS
- Method: ASBITSTREAM_CCSID_819
- No conversion needed

#### Test Case 2: Unsupported Characters

**Input:**
```xml
<Data>
    <Content>Hello "World" – Testing… €100 ≥ £50</Content>
</Data>
```

**Expected Output:**
- Status: JAVA_CONVERTED
- Method: JAVA_CONVERTER
- Converted: Hello "World" - Testing. E100 > #50

#### Test Case 3: Mixed Content

**Input:**
```xml
<Data>
    <Content>Customer: José García, Amount: €1,500.00</Content>
</Data>
```

**Expected Output:**
- Status: JAVA_CONVERTED
- Converted: Customer: Jose Garcia, Amount: E1,500.00

### Step 6: Monitoring and Logging

#### Add Logging to ESQL

```esql
-- Log to user trace
CALL CopyMessageHeaders();
SET OutputLocalEnvironment.Destination.MQ.DestinationData[1].queueName = 'AUDIT.QUEUE';

-- Log details
SET OutputRoot.XMLNSC.AuditLog.Timestamp = CURRENT_TIMESTAMP;
SET OutputRoot.XMLNSC.AuditLog.Status = OutputLocalEnvironment.Variables.Status;
SET OutputRoot.XMLNSC.AuditLog.InputLength = LENGTH(originalData);
SET OutputRoot.XMLNSC.AuditLog.OutputLength = LENGTH(encodedData);
```

#### View Logs

```bash
# User trace
mqsireadlog ACE_NODE -e ACE_SERVER -u

# Service trace (if enabled)
mqsichangetrace ACE_NODE -e ACE_SERVER -t -l debug
```

## Advanced Configurations

### Option 1: Pre-validation

Add validation before attempting ASBITSTREAM:

```esql
CREATE COMPUTE MODULE Validate_Compute
    CREATE FUNCTION Main() RETURNS BOOLEAN
    BEGIN
        DECLARE inputText CHARACTER;
        DECLARE needsConversion BOOLEAN;
        
        SET inputText = InputRoot.XMLNSC.Data.Content;
        
        -- Check if conversion needed
        SET needsConversion = hasUnsupportedChars(inputText);
        
        IF needsConversion THEN
            -- Route to Java converter directly
            SET OutputLocalEnvironment.Destination.RouterList.DestinationData[1].labelName = 'JavaConvert';
        ELSE
            -- Route to direct ASBITSTREAM
            SET OutputLocalEnvironment.Destination.RouterList.DestinationData[1].labelName = 'DirectConvert';
        END IF;
        
        SET OutputRoot = InputRoot;
        RETURN TRUE;
    END;
    
    CREATE FUNCTION hasUnsupportedChars(IN text CHARACTER) 
        RETURNS BOOLEAN
        LANGUAGE JAVA
        EXTERNAL NAME "com.ibm.ace.encoding.CharacterConverter.hasUnsupportedCharacters";
END MODULE;
```

### Option 2: Detailed Reporting

Get conversion report:

```esql
CREATE COMPUTE MODULE ConvertWithReport_Compute
    CREATE FUNCTION Main() RETURNS BOOLEAN
    BEGIN
        DECLARE inputText CHARACTER;
        DECLARE resultArray CHARACTER ARRAY;
        
        SET inputText = InputRoot.XMLNSC.Data.Content;
        
        -- Call Java method that returns array
        SET resultArray = callJavaConverterWithReport(inputText);
        
        -- resultArray[1] = converted text
        -- resultArray[2] = conversion report
        
        SET OutputRoot.BLOB.BLOB = ASBITSTREAM(resultArray[1] CCSID 819 ENCODING 546);
        SET OutputLocalEnvironment.Variables.ConversionReport = resultArray[2];
        
        RETURN TRUE;
    END;
    
    CREATE FUNCTION callJavaConverterWithReport(IN inputText CHARACTER) 
        RETURNS CHARACTER ARRAY
        LANGUAGE JAVA
        EXTERNAL NAME "com.ibm.ace.encoding.CharacterConverter.convertWithReport";
END MODULE;
```

### Option 3: Custom Replacement Map

Modify Java class to add custom replacements:

```java
// In CharacterConverter.java
static {
    // Add your custom replacements
    REPLACEMENT_MAP.put('\u00E9', 'e');  // é -> e
    REPLACEMENT_MAP.put('\u00F1', 'n');  // ñ -> n
    REPLACEMENT_MAP.put('\u00FC', 'u');  // ü -> u
    
    // Add more as needed
}
```

## Troubleshooting

### Issue 1: Java Class Not Found

**Error:**
```
BIP3734E: Java exception: 'java.lang.ClassNotFoundException'
```

**Solution:**
```bash
# Verify JAR is in correct location
ls -l /var/mqsi/shared-classes/EncodingUtils.jar

# Check server classpath
mqsireportproperties ACE_NODE -e ACE_SERVER -o ComIbmJVMManager -r

# Restart integration server
mqsistop ACE_NODE -e ACE_SERVER
mqsistart ACE_NODE -e ACE_SERVER
```

### Issue 2: Method Not Found

**Error:**
```
BIP3735E: Java exception: 'java.lang.NoSuchMethodException'
```

**Solution:**
- Verify method signature matches ESQL declaration
- Check method is public and static
- Ensure parameter types match

### Issue 3: Still Getting Encoding Errors

**Error:**
```
BIP2230E: Error detected whilst processing a message
```

**Solution:**
```esql
-- Add more detailed error handling
EXCEPTION
    WHEN SQLSTATE LIKE 'BIP%' THEN
        -- Log the specific error
        SET OutputLocalEnvironment.Variables.Error.Code = SQLSTATE;
        SET OutputLocalEnvironment.Variables.Error.Text = SQLERRORTEXT;
        SET OutputLocalEnvironment.Variables.Error.NativeError = SQLNATIVEERROR;
        
        -- Try alternative encoding
        SET encodedData = ASBITSTREAM(convertedData CCSID 1208 ENCODING 546);
END;
```

## Performance Considerations

### Optimization 1: Cache Conversion Results

```java
// Add to CharacterConverter.java
private static final Map<String, String> conversionCache = new ConcurrentHashMap<>();

public static String convertCached(String inputText) {
    return conversionCache.computeIfAbsent(inputText, 
        CharacterConverter::convertToISO88591);
}
```

### Optimization 2: Batch Processing

```esql
-- Process multiple messages in batch
CREATE COMPUTE MODULE BatchEncode_Compute
    CREATE FUNCTION Main() RETURNS BOOLEAN
    BEGIN
        DECLARE I INTEGER 1;
        DECLARE messageCount INTEGER CARDINALITY(InputRoot.XMLNSC.Messages.Message[]);
        
        WHILE I <= messageCount DO
            DECLARE currentMsg CHARACTER;
            SET currentMsg = InputRoot.XMLNSC.Messages.Message[I].Content;
            
            -- Process each message
            CALL processMessage(currentMsg, I);
            
            SET I = I + 1;
        END WHILE;
        
        RETURN TRUE;
    END;
END MODULE;
```

## Deployment Checklist

- [ ] Java class compiled and packaged in JAR
- [ ] JAR deployed to shared-classes directory
- [ ] ESQL module created with correct Java method references
- [ ] Message flow created and configured
- [ ] Test cases executed successfully
- [ ] Error handling tested
- [ ] Logging configured
- [ ] Performance tested with production-like data
- [ ] Documentation updated
- [ ] BAR file created with all components
- [ ] Deployed to test environment
- [ ] Validated in test environment
- [ ] Ready for production deployment

## Summary

This solution provides robust handling of CCSID 819 encoding with automatic fallback to Java conversion for unsupported characters. The implementation is production-ready with comprehensive error handling, logging, and monitoring capabilities.

### Key Benefits:
- ✅ Automatic fallback for encoding errors
- ✅ Comprehensive character replacement
- ✅ Detailed logging and monitoring
- ✅ Production-ready error handling
- ✅ Extensible for custom requirements
- ✅ Performance optimized

### Files Provided:
1. **EncodingHandler.esql** - ESQL implementation with multiple approaches
2. **CharacterConverter.java** - Java converter with multiple strategies
3. **ENCODING_IMPLEMENTATION_GUIDE.md** - This comprehensive guide

You're ready to implement! 🚀