import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null
    
    readonly property var geometryPlaceholder: panelContainer
    property real contentPreferredWidth: 280 * Style.uiScaleRatio
    property real contentPreferredHeight: 400 * Style.uiScaleRatio
    readonly property bool allowAttach: true
    property int itemHeight: 56
    
    property var allApps: []
    property string searchQuery: ""
    property int selectedIndex: 0
    property bool isOpen: false
    
    property var filteredApps: {
        var query = searchQuery.toLowerCase().trim();
        
        if (query === "") {
            return allApps.slice(0, 30);
        }
        
        return allApps.filter(function(app) {
            var name = (app.name || "").toLowerCase();
            var comment = (app.comment || "").toLowerCase();
            return name.includes(query) || comment.includes(query);
        }).slice(0, 30);
    }
    
    anchors.fill: parent
    
    Component.onCompleted: {
        loadApps();
    }
    
    function loadApps() {
        allApps = getAllApps();
    }
    
    function getAllApps() {
        var apps = [];
        try {
            if (typeof DesktopEntries !== 'undefined') {
                const allApps = DesktopEntries.applications.values || [];
                
                apps = allApps.filter(function(app) {
                    if (!app) return false;
                    
                    var noDisplay = app.noDisplay || false;
                    var hidden = app.hidden || false;
                    
                    return !noDisplay && !hidden;
                });
                
                apps.sort(function(a, b) {
                    var nameA = (a.name || "").toLowerCase();
                    var nameB = (b.name || "").toLowerCase();
                    return nameA.localeCompare(nameB);
                });
                
                apps = apps.map(function(app) {
                    var executableName = "";
                    
                    if (app.command && Array.isArray(app.command) && app.command.length > 0) {
                        var cmd = app.command[0];
                        var parts = cmd.split('/');
                        var executable = parts[parts.length - 1];
                        executableName = executable.split(' ')[0];
                    } else if (app.exec) {
                        var parts = app.exec.split('/');
                        var executable = parts[parts.length - 1];
                        executableName = executable.split(' ')[0];
                    } else if (app.id) {
                        executableName = app.id.replace('.desktop', '');
                    }
                    
                    app.executableName = executableName;
                    return app;
                });
                
            }
        } catch (e) {
        }
        
        return apps;
    }
    
    function launchApp(app) {
        if (pluginApi) {
            pluginApi.closePanel();
        }
        
        Qt.callLater(function() {
            try {
                if (app.command && Array.isArray(app.command) && app.command.length > 0) {
                    if (typeof Quickshell !== 'undefined' && Quickshell.execDetached) {
                        Quickshell.execDetached(app.command);
                    }
                } else if (app.execute && typeof app.execute === 'function') {
                    app.execute();
                } else if (app.exec) {
                    var command = app.exec.split(' ');
                    if (typeof Quickshell !== 'undefined' && Quickshell.execDetached) {
                        Quickshell.execDetached(command);
                    }
                }
            } catch (e) {
            }
        });
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: Color.mSurface
        radius: Style.radiusM
        
        ColumnLayout {
            anchors {
                fill: parent
                margins: Style.marginM
            }
            spacing: Style.marginM

            NTextInput {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Поиск приложений..."
                inputIconName: "search"
                
                Keys.onReturnPressed: {
                    if (filteredApps.length > 0) {
                        launchApp(filteredApps[selectedIndex]);
                    }
                }
                
                onTextChanged: {
                    searchQuery = text;
                    selectedIndex = 0;
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Color.mSurfaceVariant
                radius: Style.radiusM
                border.width: Style.borderS
                border.color: Color.mOutline

                NListView {
                    id: appListView
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    model: filteredApps
                    spacing: 2
                    
                    delegate: Rectangle {
                        id: appDelegate
                        width: appListView.width
                        height: itemHeight
                        color: selectedIndex === index ? Color.mPrimary : "transparent"
                        radius: Style.radiusS
                        border.width: Style.borderS
                        border.color: mouseArea.containsMouse ? Color.mOutline : "transparent"

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: selectedIndex = index
                            onClicked: launchApp(modelData)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Style.marginM
                            spacing: Style.marginM

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 8
                                color: Color.mSurfaceVariant
                                
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    fillMode: Image.PreserveAspectFit
                                    source: {
                                        if (!modelData.icon) return "";
                                        if (modelData.icon.includes("/")) {
                                            return "file://" + modelData.icon;
                                        }
                                        return "image://icon/" + modelData.icon;
                                    }
                                    asynchronous: true
                                    visible: status === Image.Ready
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: Color.mSurfaceVariant
                                        radius: 8
                                        z: -1
                                        visible: parent.status === Image.Loading || parent.status === Image.Error
                                    }
                                }
                                
                                NIcon {
                                    anchors.centerIn: parent
                                    icon: "apps"
                                    color: Color.mOnSurfaceVariant
                                    width: 24
                                    height: 24
                                    visible: !modelData.icon || 
                                            (typeof modelData.icon === 'string' && modelData.icon.trim() === '')
                                }
                            }

                            NText {
                                text: modelData.name || "Unknown"
                                color: selectedIndex === index ? Color.mOnPrimary : Color.mOnSurface
                                font.pointSize: Style.fontSizeS
                                font.weight: selectedIndex === index ? Font.Bold : Font.Normal
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Color.mPrimary
                                opacity: selectedIndex === index ? 1 : 0
                                
                                NIcon {
                                    anchors.centerIn: parent
                                    icon: "chevron-right"
                                    color: Color.mOnPrimary
                                    width: 16
                                    height: 16
                                }
                            }
                        }
                    }
                }

                Item {
                    anchors.centerIn: parent
                    width: parent.width - 40
                    height: 120
                    visible: filteredApps.length === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Style.marginM
                        
                        NIcon {
                            icon: searchQuery === "" ? "apps" : "search-off"
                            color: Color.mOnSurfaceVariant
                            width: 64
                            height: 64
                            opacity: 0.5
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        NText {
                            text: searchQuery === "" 
                                  ? "Начните вводить название приложения" 
                                  : "Ничего не найдено"
                            color: Color.mOnSurfaceVariant
                            font.pointSize: Style.fontSizeM
                            font.weight: Font.Medium
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        NText {
                            text: searchQuery === "" 
                                  ? "Используйте поле поиска выше" 
                                  : "Попробуйте другой запрос"
                            color: Color.mOnSurfaceVariant
                            font.pointSize: Style.fontSizeS
                            opacity: 0.7
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 30 : 0
                color: "transparent"
                
                visible: filteredApps.length > 0

                NText {
                    anchors.centerIn: parent
                    text: filteredApps.length + " приложений"
                    color: Color.mOnSurfaceVariant
                    font.pointSize: Style.fontSizeS
                    opacity: 0.7
                }
            }
        }
    }
}