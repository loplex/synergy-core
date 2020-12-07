// https://www.qt.io/blog/qt-online-installer-3.2.3-released
// https://www.qt.io/blog/option-to-provide-anonymous-usage-statistics-enabled

// https://wiki.qt.io/Online_Installer_4.x#Installing_unattended_with_CLI
// https://github.com/qtproject/qtsdk/tree/master/packaging-tools/configurations/pkg_templates/pkg_58


var env_output = installer.environmentVariable("QT_INSTALLER_DIR");
if (!env_output) {
	env_output = "C:\\Qt";
}

var env_list_packages = installer.environmentVariable("QT_INSTALLER_LIST_PACKAGES");
if (env_list_packages) {
	env_output = "C:\\QtTemp";
}

var env_packages = installer.environmentVariable("QT_INSTALLER_PACKAGES");


function abortInstaller()
{
    installer.setDefaultPageVisible(QInstaller.Introduction, false);
    installer.setDefaultPageVisible(QInstaller.TargetDirectory, false);
    installer.setDefaultPageVisible(QInstaller.ComponentSelection, false);
    installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false);
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
    installer.setDefaultPageVisible(QInstaller.PerformInstallation, false);
    installer.setDefaultPageVisible(QInstaller.LicenseCheck, false);
    var abortText = "<font color='red' size=3>" + qsTr("Installation failed:") + "</font>";
    var error_list = installer.value("component_errors").split(";;;");
    abortText += "<ul>";
    // ignore the first empty one
    for (var i = 0; i < error_list.length; ++i) {
        if (error_list[i] !== "") {
            log(error_list[i]);
            abortText += "<li>" + error_list[i] + "</li>"
        }
    }
    abortText += "</ul>";
    installer.setValue("FinishedText", abortText);
}
function log() {
    var msg = ["QTCI: "].concat([].slice.call(arguments));
    console.log(msg.join(" "));
}
function printObject(object) {
	var lines = [];
	for (var i in object) {
		lines.push([i, object[i]].join(" "));
	}
	log(lines.join(","));
}
var status = {
	widget: null,
	finishedPageVisible: false,
	installationFinished: false
}
function tryFinish() {
	if (status.finishedPageVisible && status.installationFinished) {
        if (status.widget.LaunchQtCreatorCheckBoxForm) {
            // Disable this checkbox for minimal platform
            status.widget.LaunchQtCreatorCheckBoxForm.launchQtCreatorCheckBox.setChecked(false);
        }
        if (status.widget.RunItCheckBox) {
            // LaunchQtCreatorCheckBoxForm may not work for newer versions.
            status.widget.RunItCheckBox.setChecked(false);
        }
        log("Press Finish Button");
	    gui.clickButton(buttons.FinishButton);
	}
}
function Controller() {
    installer.installationFinished.connect(function() {
		status.installationFinished = true;
        gui.clickButton(buttons.NextButton);
        tryFinish();
    });
    installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
    installer.setMessageBoxAutomaticAnswer("installationErrorWithRetry", QMessageBox.Ignore);
    
    // Allow to cancel installation for arguments --list-packages
    installer.setMessageBoxAutomaticAnswer("cancelInstallation", QMessageBox.Yes);
}
Controller.prototype.WelcomePageCallback = function() {
    log("Welcome Page");
//    gui.clickButton(buttons.NextButton);
    gui.clickButton(buttons.NextButton, 3000);
//    var widget = gui.currentPageWidget();
//    widget.completeChanged.connect(function() {
//        gui.clickButton(buttons.NextButton);
//    });
}
Controller.prototype.ObligationsPageCallback = function() {
    log("Obligations Page");
    var page = gui.pageWidgetByObjectName("ObligationsPage");
    page.obligationsAgreement.setChecked(true);
    var individualCheckbox = gui.findChild(page, "IndividualPerson")
    if (individualCheckbox) {
        individualCheckbox.checked = true;
    }
    page.completeChanged();
    gui.clickButton(buttons.NextButton);
}
Controller.prototype.DynamicTelemetryPluginFormCallback = function() {
    log("Telemetry Page");
    var page = gui.pageWidgetByObjectName("DynamicTelemetryPluginForm");
    page.statisticGroupBox.disableStatisticRadioButton.setChecked(true);
    gui.clickButton(buttons.NextButton);
}
Controller.prototype.CredentialsPageCallback = function() {
    log("CredentialsPageCallback");
    gui.clickButton(buttons.NextButton);

//    var page = gui.pageWidgetByObjectName("CredentialsPage");
//    page.loginWidget.EmailLineEdit.setText("MYEMAIL");
//    page.loginWidget.PasswordLineEdit.setText("MYPASSWORD");
//    gui.clickButton(buttons.NextButton);
//	var login = installer.environmentVariable("QT_CI_LOGIN");
//	var password = installer.environmentVariable("QT_CI_PASSWORD");
//	if (login === "" || password === "") {
//		gui.clickButton(buttons.CommitButton);
//	} else {
//        var widget = gui.currentPageWidget();
//	    widget.loginWidget.EmailLineEdit.setText(login);
//	    widget.loginWidget.PasswordLineEdit.setText(password);
//        gui.clickButton(buttons.CommitButton);
//    }
}
Controller.prototype.ComponentSelectionPageCallback = function() {
    log("ComponentSelectionPageCallback");
    function list_packages() {
      var components = installer.components();
      log("Available components: " + components.length);
      var packages = ["Packages: "];
      for (var i = 0 ; i < components.length ;i++) {
          packages.push(components[i].name);
      }
      log(packages.join("\n"));
    }
      
    if (env_list_packages) {
        list_packages();
        gui.clickButton(buttons.CancelButton);
        return;
    }
    log("Select components");
    function trim(str) {
        return str.replace(/^ +/,"").replace(/ *$/,"");
    }
    var widget = gui.currentPageWidget();
    var packages = trim(env_packages).split(",");
    if (packages.length > 0 && packages[0] !== "") {
        widget.deselectAll();
        var components = installer.components();
        var allfound = true;
        for (var i in packages) {
            var pkg = trim(packages[i]);
            var found = false;
            for (var j in components) {
                if (components[j].name === pkg) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                allfound = false;
                log("ERROR: Package " + pkg + " not found.");
            } else {
                log("Select " + pkg);
                widget.selectComponent(pkg);
            }
        }
        if (!allfound) {
            list_packages();
            // TODO: figure out how to set non-zero exit status.
            gui.clickButton(buttons.CancelButton);
            return;
        }
    } else {
       log("Use default component list");
    }
    gui.clickButton(buttons.NextButton, 3000);
}
Controller.prototype.IntroductionPageCallback = function() {
    log("Introduction Page");
    log("Retrieving meta information from remote repository");
    gui.clickButton(buttons.NextButton);
}
Controller.prototype.TargetDirectoryPageCallback = function() {
    log("Set target installation page: " + env_output);
    var widget = gui.currentPageWidget();
    if (widget != null) {
        widget.TargetDirectoryLineEdit.setText(env_output);
    }
    
    gui.clickButton(buttons.NextButton);
}
Controller.prototype.LicenseAgreementPageCallback = function() {
    log("Accept license agreement");
    var widget = gui.currentPageWidget();
    if (widget != null) {
        widget.AcceptLicenseRadioButton.setChecked(true);
    }
    gui.clickButton(buttons.NextButton);
}
Controller.prototype.StartMenuDirectoryPageCallback = function() {
    log("Confirm Start Menu shortcuts");
    gui.clickButton(buttons.NextButton, 500);
}
Controller.prototype.ReadyForInstallationPageCallback = function() {
    log("Ready to install");
    // Bug? If commit button pressed too quickly finished callback might not show the checkbox to disable running qt creator
    // Behaviour started around 5.10. You don't actually have to press this button at all with those versions, even though gui.isButtonEnabled() returns true.
    
    gui.clickButton(buttons.CommitButton, 200);
}
Controller.prototype.PerformInstallationPageCallback = function() {
    log("PerformInstallationPageCallback");
    gui.clickButton(buttons.CommitButton);
}
Controller.prototype.FinishedPageCallback = function() {
    log("FinishedPageCallback");
    var widget = gui.currentPageWidget();
	// Bug? Qt 5.9.5 and Qt 5.9.6 installer show finished page before the installation completed
	// Don't press "finishButton" immediately
    
	status.finishedPageVisible = true;
	status.widget = widget;
	tryFinish();   
}
