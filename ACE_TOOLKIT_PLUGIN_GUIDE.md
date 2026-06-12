# ACE FlowSmith AI - Toolkit Plugin Development Guide

## Overview

This guide explains how to create an Eclipse plugin for IBM App Connect Enterprise (ACE) Toolkit that integrates ACE FlowSmith AI directly into the development environment.

## Understanding ACE Toolkit Architecture

### ACE Toolkit = Eclipse IDE
- **Base**: Eclipse IDE (typically Eclipse 4.x)
- **IBM Extensions**: ACE-specific plugins and perspectives
- **Plugin System**: Eclipse Plugin Development Environment (PDE)
- **Language**: Java (Eclipse plugins are written in Java)

### Key Components
1. **Eclipse Workbench** - Main UI framework
2. **ACE Perspective** - Custom view layout for ACE development
3. **Message Flow Editor** - Visual editor for .msgflow files
4. **Integration Nodes View** - Server management
5. **Application Development View** - Project explorer

## Plugin Development Approach

### Option 1: Eclipse Plugin (Recommended for Full Integration)

#### Prerequisites
```bash
# Required Software
- IBM App Connect Enterprise Toolkit (v12.x)
- Eclipse Plugin Development Environment (PDE)
- Java Development Kit (JDK 11 or 17)
- Maven or Gradle for dependency management
```

#### Plugin Structure
```
com.ibm.ace.flowsmith.plugin/
├── META-INF/
│   └── MANIFEST.MF              # Plugin metadata
├── plugin.xml                    # Extension points
├── src/
│   └── com/ibm/ace/flowsmith/
│       ├── Activator.java       # Plugin lifecycle
│       ├── handlers/
│       │   ├── GenerateFlowHandler.java
│       │   └── ValidateFlowHandler.java
│       ├── views/
│       │   ├── FlowSmithView.java
│       │   └── RequirementsView.java
│       ├── wizards/
│       │   └── NewFlowWizard.java
│       ├── editors/
│       │   └── FlowSmithEditor.java
│       ├── services/
│       │   ├── AIService.java
│       │   └── FlowGeneratorService.java
│       └── ui/
│           ├── dialogs/
│           └── preferences/
├── icons/                        # UI icons
├── lib/                          # External JARs
├── build.properties
└── pom.xml                       # Maven build
```

#### Step 1: Create Plugin Project

**MANIFEST.MF**
```manifest
Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: ACE FlowSmith AI Plugin
Bundle-SymbolicName: com.ibm.ace.flowsmith.plugin;singleton:=true
Bundle-Version: 1.0.0.qualifier
Bundle-Activator: com.ibm.ace.flowsmith.Activator
Bundle-Vendor: IBM Hackathon 2026
Require-Bundle: org.eclipse.ui,
 org.eclipse.core.runtime,
 org.eclipse.core.resources,
 org.eclipse.jface.text,
 com.ibm.etools.mft.ui,
 com.ibm.etools.mft.core
Bundle-RequiredExecutionEnvironment: JavaSE-11
Bundle-ActivationPolicy: lazy
Export-Package: com.ibm.ace.flowsmith
```

**plugin.xml**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.4"?>
<plugin>
   <!-- Add menu item to ACE Toolkit -->
   <extension point="org.eclipse.ui.menus">
      <menuContribution locationURI="menu:org.eclipse.ui.main.menu">
         <menu id="com.ibm.ace.flowsmith.menu" label="FlowSmith AI">
            <command
               commandId="com.ibm.ace.flowsmith.generateFlow"
               label="Generate Flow from Requirements"
               icon="icons/generate.png">
            </command>
            <command
               commandId="com.ibm.ace.flowsmith.validateFlow"
               label="Validate Flow with AI"
               icon="icons/validate.png">
            </command>
            <command
               commandId="com.ibm.ace.flowsmith.suggestSubflows"
               label="Suggest Reusable Subflows"
               icon="icons/suggest.png">
            </command>
         </menu>
      </menuContribution>
      
      <!-- Context menu in Project Explorer -->
      <menuContribution locationURI="popup:org.eclipse.ui.navigator.ProjectExplorer#PopupMenu">
         <menu id="com.ibm.ace.flowsmith.contextmenu" label="FlowSmith AI">
            <command
               commandId="com.ibm.ace.flowsmith.generateFlow"
               label="Generate Flow Here">
            </command>
         </menu>
      </menuContribution>
   </extension>

   <!-- Define commands -->
   <extension point="org.eclipse.ui.commands">
      <command
         id="com.ibm.ace.flowsmith.generateFlow"
         name="Generate Flow"
         description="Generate ACE flow from natural language requirements">
      </command>
      <command
         id="com.ibm.ace.flowsmith.validateFlow"
         name="Validate Flow"
         description="Validate flow against best practices">
      </command>
      <command
         id="com.ibm.ace.flowsmith.suggestSubflows"
         name="Suggest Subflows"
         description="Suggest reusable subflows">
      </command>
   </extension>

   <!-- Command handlers -->
   <extension point="org.eclipse.ui.handlers">
      <handler
         commandId="com.ibm.ace.flowsmith.generateFlow"
         class="com.ibm.ace.flowsmith.handlers.GenerateFlowHandler">
      </handler>
      <handler
         commandId="com.ibm.ace.flowsmith.validateFlow"
         class="com.ibm.ace.flowsmith.handlers.ValidateFlowHandler">
      </handler>
      <handler
         commandId="com.ibm.ace.flowsmith.suggestSubflows"
         class="com.ibm.ace.flowsmith.handlers.SuggestSubflowsHandler">
      </handler>
   </extension>

   <!-- Add custom view -->
   <extension point="org.eclipse.ui.views">
      <view
         id="com.ibm.ace.flowsmith.views.FlowSmithView"
         name="FlowSmith AI"
         icon="icons/flowsmith.png"
         class="com.ibm.ace.flowsmith.views.FlowSmithView"
         category="com.ibm.etools.mft.ui.views">
      </view>
   </extension>

   <!-- Preferences page -->
   <extension point="org.eclipse.ui.preferencePages">
      <page
         id="com.ibm.ace.flowsmith.preferences"
         name="FlowSmith AI"
         class="com.ibm.ace.flowsmith.ui.preferences.FlowSmithPreferencePage">
      </page>
   </extension>

   <!-- New Flow Wizard -->
   <extension point="org.eclipse.ui.newWizards">
      <wizard
         id="com.ibm.ace.flowsmith.wizards.NewFlowWizard"
         name="AI-Generated Message Flow"
         class="com.ibm.ace.flowsmith.wizards.NewFlowWizard"
         category="com.ibm.etools.mft.ui.wizards"
         icon="icons/new_flow.png">
         <description>Create a new message flow using AI generation</description>
      </wizard>
   </extension>
</plugin>
```

#### Step 2: Implement Core Classes

**Activator.java** - Plugin Lifecycle
```java
package com.ibm.ace.flowsmith;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

public class Activator extends AbstractUIPlugin {
    public static final String PLUGIN_ID = "com.ibm.ace.flowsmith.plugin";
    private static Activator plugin;

    public void start(BundleContext context) throws Exception {
        super.start(context);
        plugin = this;
        System.out.println("ACE FlowSmith AI Plugin Started!");
    }

    public void stop(BundleContext context) throws Exception {
        plugin = null;
        super.stop(context);
    }

    public static Activator getDefault() {
        return plugin;
    }
}
```

**GenerateFlowHandler.java** - Main Command Handler
```java
package com.ibm.ace.flowsmith.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.handlers.HandlerUtil;

import com.ibm.ace.flowsmith.wizards.FlowGenerationWizard;
import org.eclipse.jface.wizard.WizardDialog;

public class GenerateFlowHandler extends AbstractHandler {
    
    @Override
    public Object execute(ExecutionEvent event) throws ExecutionException {
        Shell shell = HandlerUtil.getActiveShell(event);
        
        // Open wizard for flow generation
        FlowGenerationWizard wizard = new FlowGenerationWizard();
        WizardDialog dialog = new WizardDialog(shell, wizard);
        dialog.setTitle("Generate ACE Flow with AI");
        dialog.open();
        
        return null;
    }
}
```

**FlowGenerationWizard.java** - User Input Wizard
```java
package com.ibm.ace.flowsmith.wizards;

import org.eclipse.jface.wizard.Wizard;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.*;

import com.ibm.ace.flowsmith.services.AIService;
import com.ibm.ace.flowsmith.services.FlowGeneratorService;

public class FlowGenerationWizard extends Wizard {
    private RequirementsPage requirementsPage;
    private OptionsPage optionsPage;

    public FlowGenerationWizard() {
        setWindowTitle("Generate ACE Flow with AI");
        setNeedsProgressMonitor(true);
    }

    @Override
    public void addPages() {
        requirementsPage = new RequirementsPage();
        optionsPage = new OptionsPage();
        addPage(requirementsPage);
        addPage(optionsPage);
    }

    @Override
    public boolean performFinish() {
        try {
            // Get user input
            String requirements = requirementsPage.getRequirements();
            String flowName = requirementsPage.getFlowName();
            String projectName = optionsPage.getProjectName();
            
            // Call AI service to generate flow
            AIService aiService = new AIService();
            String flowXML = aiService.generateFlow(requirements);
            
            // Create flow in workspace
            FlowGeneratorService generator = new FlowGeneratorService();
            generator.createFlowInWorkspace(projectName, flowName, flowXML);
            
            MessageDialog.openInformation(
                getShell(),
                "Success",
                "Flow '" + flowName + "' generated successfully!"
            );
            
            return true;
        } catch (Exception e) {
            MessageDialog.openError(
                getShell(),
                "Error",
                "Failed to generate flow: " + e.getMessage()
            );
            return false;
        }
    }
}

class RequirementsPage extends WizardPage {
    private Text requirementsText;
    private Text flowNameText;

    protected RequirementsPage() {
        super("requirements");
        setTitle("Flow Requirements");
        setDescription("Enter your integration requirements in natural language");
    }

    @Override
    public void createControl(Composite parent) {
        Composite container = new Composite(parent, SWT.NONE);
        GridLayout layout = new GridLayout(2, false);
        container.setLayout(layout);

        // Flow name
        Label nameLabel = new Label(container, SWT.NONE);
        nameLabel.setText("Flow Name:");
        flowNameText = new Text(container, SWT.BORDER);
        flowNameText.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

        // Requirements
        Label reqLabel = new Label(container, SWT.NONE);
        reqLabel.setText("Requirements:");
        reqLabel.setLayoutData(new GridData(SWT.LEFT, SWT.TOP, false, false));
        
        requirementsText = new Text(container, SWT.BORDER | SWT.MULTI | SWT.WRAP | SWT.V_SCROLL);
        GridData gd = new GridData(GridData.FILL_BOTH);
        gd.heightHint = 200;
        requirementsText.setLayoutData(gd);
        requirementsText.setText("Example:\nCreate a REST API that:\n1. Receives customer order\n2. Validates customer in database\n3. Checks inventory\n4. Calculates price with tax\n5. Inserts order into database\n6. Returns confirmation");

        setControl(container);
    }

    public String getRequirements() {
        return requirementsText.getText();
    }

    public String getFlowName() {
        return flowNameText.getText();
    }
}

class OptionsPage extends WizardPage {
    private Combo projectCombo;

    protected OptionsPage() {
        super("options");
        setTitle("Generation Options");
        setDescription("Select target project and options");
    }

    @Override
    public void createControl(Composite parent) {
        Composite container = new Composite(parent, SWT.NONE);
        GridLayout layout = new GridLayout(2, false);
        container.setLayout(layout);

        Label projectLabel = new Label(container, SWT.NONE);
        projectLabel.setText("Target Project:");
        
        projectCombo = new Combo(container, SWT.DROP_DOWN | SWT.READ_ONLY);
        projectCombo.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        
        // Populate with ACE projects in workspace
        projectCombo.setItems(new String[]{"CustomerOrderApp", "InventoryApp", "PaymentApp"});
        projectCombo.select(0);

        setControl(container);
    }

    public String getProjectName() {
        return projectCombo.getText();
    }
}
```

**AIService.java** - AI Integration
```java
package com.ibm.ace.flowsmith.services;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import org.json.JSONObject;

public class AIService {
    private static final String API_URL = "http://localhost:8000/api/v1/generate";
    private HttpClient httpClient;

    public AIService() {
        this.httpClient = HttpClient.newHttpClient();
    }

    public String generateFlow(String requirements) throws Exception {
        // Create request payload
        JSONObject payload = new JSONObject();
        payload.put("requirements", requirements);
        payload.put("format", "msgflow");

        // Send HTTP request to FlowSmith AI backend
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(API_URL))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
            .build();

        HttpResponse<String> response = httpClient.send(
            request,
            HttpResponse.BodyHandlers.ofString()
        );

        if (response.statusCode() == 200) {
            JSONObject result = new JSONObject(response.body());
            return result.getString("flow_xml");
        } else {
            throw new Exception("AI service returned error: " + response.statusCode());
        }
    }
}
```

**FlowGeneratorService.java** - Workspace Integration
```java
package com.ibm.ace.flowsmith.services;

import org.eclipse.core.resources.*;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import java.io.ByteArrayInputStream;

public class FlowGeneratorService {
    
    public void createFlowInWorkspace(String projectName, String flowName, String flowXML) 
            throws CoreException {
        
        // Get workspace root
        IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
        
        // Get project
        IProject project = root.getProject(projectName);
        if (!project.exists()) {
            throw new CoreException(null);
        }
        
        // Create .msgflow file
        IFile flowFile = project.getFile(new Path(flowName + ".msgflow"));
        ByteArrayInputStream source = new ByteArrayInputStream(flowXML.getBytes());
        
        if (flowFile.exists()) {
            flowFile.setContents(source, IResource.FORCE, null);
        } else {
            flowFile.create(source, IResource.FORCE, null);
        }
        
        // Refresh project
        project.refreshLocal(IResource.DEPTH_INFINITE, null);
    }
}
```

**FlowSmithView.java** - Custom View Panel
```java
package com.ibm.ace.flowsmith.views;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.ui.part.ViewPart;

public class FlowSmithView extends ViewPart {
    public static final String ID = "com.ibm.ace.flowsmith.views.FlowSmithView";
    private Text statusText;

    @Override
    public void createPartControl(Composite parent) {
        parent.setLayout(new GridLayout(1, false));
        
        statusText = new Text(parent, SWT.BORDER | SWT.MULTI | SWT.READ_ONLY | SWT.WRAP);
        statusText.setLayoutData(new GridData(GridData.FILL_BOTH));
        statusText.setText("FlowSmith AI Ready\n\nUse the menu: FlowSmith AI > Generate Flow from Requirements");
    }

    @Override
    public void setFocus() {
        statusText.setFocus();
    }

    public void updateStatus(String message) {
        statusText.append("\n" + message);
    }
}
```

#### Step 3: Build Configuration

**pom.xml** - Maven Build
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.ibm.ace</groupId>
    <artifactId>flowsmith-plugin</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>eclipse-plugin</packaging>

    <properties>
        <tycho.version>2.7.5</tycho.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <build>
        <plugins>
            <plugin>
                <groupId>org.eclipse.tycho</groupId>
                <artifactId>tycho-maven-plugin</artifactId>
                <version>${tycho.version}</version>
                <extensions>true</extensions>
            </plugin>
        </plugins>
    </build>
</project>
```

**build.properties**
```properties
source.. = src/
output.. = bin/
bin.includes = META-INF/,\
               .,\
               plugin.xml,\
               icons/,\
               lib/
```

#### Step 4: Build and Install

```bash
# Build plugin
mvn clean package

# This creates:
# target/com.ibm.ace.flowsmith.plugin_1.0.0.jar

# Install in ACE Toolkit
# Option 1: Copy to dropins folder
cp target/*.jar /opt/IBM/ACE/12.0/tools/dropins/

# Option 2: Install via Eclipse
# Help > Install New Software > Add > Archive
# Select the JAR file

# Restart ACE Toolkit
```

### Option 2: External Tool Integration (Simpler Alternative)

If building a full Eclipse plugin is too complex, you can integrate as an external tool:

**external_tool_config.xml**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<externalTools>
    <tool name="FlowSmith AI Generator"
          location="/usr/local/bin/flowsmith-cli"
          arguments="generate --workspace ${workspace_loc} --project ${project_name}"
          workingDirectory="${workspace_loc}"
          captureOutput="true"/>
</externalTools>
```

Add to ACE Toolkit:
1. Run > External Tools > External Tools Configurations
2. Create new Program configuration
3. Set location to your FlowSmith CLI tool
4. Configure arguments with Eclipse variables

### Option 3: REST API + Browser Integration

**Lightweight approach using embedded browser:**

```java
// Add browser view to plugin
import org.eclipse.swt.browser.Browser;

public class FlowSmithBrowserView extends ViewPart {
    private Browser browser;

    @Override
    public void createPartControl(Composite parent) {
        browser = new Browser(parent, SWT.NONE);
        browser.setUrl("http://localhost:3000/flowsmith-ui");
    }
}
```

## Installation Methods

### Method 1: Update Site (Professional)
1. Create update site project
2. Build feature and update site
3. Users install via: Help > Install New Software > Add Site

### Method 2: Dropins Folder (Simple)
```bash
# Copy JAR to dropins
cp plugin.jar $ACE_TOOLKIT_HOME/dropins/

# Restart Toolkit
```

### Method 3: P2 Repository (Enterprise)
Host on internal server, users add repository URL

## Testing the Plugin

```java
// JUnit test for plugin
public class FlowGenerationTest {
    @Test
    public void testFlowGeneration() {
        AIService service = new AIService();
        String requirements = "Create REST API for customer orders";
        String result = service.generateFlow(requirements);
        assertNotNull(result);
        assertTrue(result.contains("<ComIbmWSInput"));
    }
}
```

## User Experience

### After Installation:

1. **Menu Bar**: FlowSmith AI menu appears
2. **Context Menu**: Right-click project > FlowSmith AI
3. **View**: Window > Show View > FlowSmith AI
4. **Wizard**: File > New > AI-Generated Message Flow
5. **Toolbar**: FlowSmith AI icon in toolbar

### Workflow:
1. User clicks "Generate Flow from Requirements"
2. Wizard opens with text area
3. User enters natural language requirements
4. Clicks "Generate"
5. AI generates flow XML
6. Flow appears in project, opens in editor
7. User customizes and tests

## Advanced Features

### Real-time Validation
```java
// Add marker to flow editor
IMarker marker = flowFile.createMarker(IMarker.PROBLEM);
marker.setAttribute(IMarker.MESSAGE, "Consider using ErrorHandler subflow");
marker.setAttribute(IMarker.SEVERITY, IMarker.SEVERITY_WARNING);
```

### Code Completion
```java
// Integrate with content assist
public class FlowSmithContentAssistProcessor implements IContentAssistProcessor {
    @Override
    public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer, int offset) {
        // Suggest subflows based on context
        return proposals;
    }
}
```

### Quick Fixes
```java
// Provide quick fix for issues
public class FlowSmithQuickFix implements IMarkerResolutionGenerator {
    @Override
    public IMarkerResolution[] getResolutions(IMarker marker) {
        return new IMarkerResolution[] {
            new AddSubflowResolution(),
            new AddErrorHandlingResolution()
        };
    }
}
```

## Distribution

### Create Update Site
```bash
# Build update site
mvn clean install

# Upload to server
scp -r target/repository/* user@server:/var/www/flowsmith-updates/

# Users add: http://server/flowsmith-updates
```

### Enterprise Deployment
```bash
# Silent install script
/opt/IBM/ACE/12.0/tools/eclipse \
  -application org.eclipse.equinox.p2.director \
  -repository http://internal-server/flowsmith-updates \
  -installIU com.ibm.ace.flowsmith.feature.group
```

## Summary

**Yes, you can install ACE FlowSmith AI as a plugin in IBM App Connect Toolkit!**

### Three Approaches:
1. **Full Eclipse Plugin** (Most integrated, requires Java development)
2. **External Tool** (Simpler, less integrated)
3. **Browser View** (Easiest, web-based UI)

### Recommended Path:
1. Start with **External Tool** for quick prototype
2. Build **Browser View** for better UX
3. Develop **Full Plugin** for production

The full plugin provides the best user experience with native integration into the ACE Toolkit workflow!