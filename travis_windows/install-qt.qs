// defaults
const DEFAULT_QT_INSTALL_DIR = "C:\\Qt";
const DEFAULT_QT_TMP_INSTALL_DIR = "C:\\QtTemp";  // used in "only-list packages" (QT_INSTALL_ONLY_LIST_PACKAGES) mode

// configuration using env. variables
const env_list_packages = installer.environmentVariable("QT_INSTALL_ONLY_LIST_PACKAGES");
const env_env_output = installer.environmentVariable(env_list_packages ? "QT_INSTALL_ONLY_LIST_PACKAGES_TMPDIR" : "QT_INSTALL_DIR");
const env_output = env_env_output ? env_env_output : (env_list_packages ? DEFAULT_QT_TMP_INSTALL_DIR : DEFAULT_QT_INSTALL_DIR);
const env_packages = installer.environmentVariable("QT_INSTALL_PACKAGES");
const env_login = installer.environmentVariable("QT_INSTALL_ACCOUNT_LOGIN");
const env_password = installer.environmentVariable("QT_INSTALL_ACCOUNT_PASSWORD");


function abortInstaller() {
    installer.setDefaultPageVisible(QInstaller.Introduction, false);
    installer.setDefaultPageVisible(QInstaller.TargetDirectory, false);
    installer.setDefaultPageVisible(QInstaller.ComponentSelection, false);
    installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false);
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
    installer.setDefaultPageVisible(QInstaller.PerformInstallation, false);
    installer.setDefaultPageVisible(QInstaller.LicenseCheck, false);
    let abortText = "<font color='red' size=3>" + qsTr("Installation failed:") + "</font>";
    const error_list = installer.value("component_errors").split(";;;");
    abortText += "<ul>";
    // ignore the first empty one
    for (let i = 0; i < error_list.length; ++i) {
        if (error_list[i] !== "") {
            log(error_list[i]);
            abortText += "<li>" + error_list[i] + "</li>"
        }
    }
    abortText += "</ul>";
    installer.setValue("FinishedText", abortText);
}

function log() {
    const msg = ["QTCI: "].concat([].slice.call(arguments));
    console.log(msg.join(" "));
}

function printObject(object) {
    const lines = [];
    for (let i in object) {
		// noinspection JSUnfilteredForInLoop
        lines.push([i, object[i]].join(" "));
	}
	log(lines.join(","));
}


const status = {
    widget: null,
    finishedPageVisible: false,
    installationFinished: false
};

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

// noinspection JSUnusedGlobalSymbols
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
    const page = gui.pageWidgetByObjectName("ObligationsPage");
    page.obligationsAgreement.setChecked(true);
    const individualCheckbox = gui.findChild(page, "IndividualPerson");
    if (individualCheckbox) {
        individualCheckbox.checked = true;
    }
    page.completeChanged();
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.DynamicTelemetryPluginFormCallback = function() {
    log("DynamicTelemetryPluginFormCallback");
    const page = gui.pageWidgetByObjectName("DynamicTelemetryPluginForm");
    page.statisticGroupBox.disableStatisticRadioButton.setChecked(true);
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.CredentialsPageCallback = function() {
    log("Credentials Page");
    if (env_login || env_password) {
        const widget = gui.currentPageWidget();
        widget.loginWidget.EmailLineEdit.setText(login);
        widget.loginWidget.PasswordLineEdit.setText(password);
    }
    gui.clickButton(buttons.CommitButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
    log("Component Selection Page");
    function list_packages() {
        const components = installer.components();
        log("Available components: " + components.length);
        const packages = ["Packages: "];
        for (let i = 0 ; i < components.length ; i++) {
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

    const widget = gui.currentPageWidget();
    var packages = trim(env_packages).split(",");
    if (packages.length > 0 && packages[0] !== "") {
        widget.deselectAll();
        var components = installer.components();
        let allfound = true;
        for (var i in packages) {
            // noinspection JSUnfilteredForInLoop
            const pkg = trim(packages[i]);
            let found = false;
            for (let j in components) {
                // noinspection JSUnfilteredForInLoop
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
    log("Target Directory Page");
    log("Set target installation page: " + env_output);
    const widget = gui.currentPageWidget();
    if (widget != null) {
        widget.TargetDirectoryLineEdit.setText(env_output);
    }
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    log("License Agreement Page");
    log("Accept license agreement");
    const widget = gui.currentPageWidget();
    if (widget != null) {
        widget.AcceptLicenseRadioButton.setChecked(true);
    }
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function() {
    log("Start Menu Directory Page");
    log("Confirm Start Menu shortcuts");
    gui.clickButton(buttons.NextButton, 500);
}

Controller.prototype.ReadyForInstallationPageCallback = function() {
    log("Ready For Installation Page");
    // Bug? If commit button pressed too quickly finished callback might not show the checkbox to disable running qt creator
    // Behaviour started around 5.10. You don't actually have to press this button at all with those versions, even though gui.isButtonEnabled() returns true.
    gui.clickButton(buttons.CommitButton, 200);
}

Controller.prototype.PerformInstallationPageCallback = function() {
    log("Perform Installation Page");
    gui.clickButton(buttons.CommitButton);
}

Controller.prototype.FinishedPageCallback = function() {
    log("Finished Page");
    const widget = gui.currentPageWidget();
    // Bug? Qt 5.9.5 and Qt 5.9.6 installer show finished page before the installation completed
	// Don't press "finishButton" immediately
	status.finishedPageVisible = true;
	status.widget = widget;
	tryFinish();   
}
