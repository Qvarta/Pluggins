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

    anchors.fill: parent

    NPopupContextMenu {
        id: appContextMenu
        itemHeight: 36
        minWidth: 160
        
        property var currentApp: null
        
        onTriggered: function(action, item) {
            if (currentApp) {
                if (action === "launch") {
                    if (pluginApi && pluginApi.mainInstance) {
                        pluginApi.mainInstance.launchApp(currentApp);
                    }
                } else if (action === "add-to-favorites") {
                    if (pluginApi && pluginApi.mainInstance) {
                        pluginApi.mainInstance.addToFavorites(currentApp);
                    }
                    Qt.callLater(updateMenuModel);
                } else if (action === "remove-from-favorites") {
                    if (pluginApi && pluginApi.mainInstance) {
                        pluginApi.mainInstance.removeFromFavorites(currentApp.id);
                    }
                    Qt.callLater(updateMenuModel);
                }
            }
            close();
        }
        
        function updateMenuModel() {
            if (!currentApp) return;
            
            var isFav = pluginApi && pluginApi.mainInstance ? 
                       pluginApi.mainInstance.isFavorite(currentApp.id) : false;
            
            var newModel = [
                {
                    "label": "Запустить",
                    "action": "launch",
                    "icon": "player-play",
                    "enabled": true
                }
            ];
            
            if (isFav) {
                newModel.push({
                    "label": "Удалить из избранного",
                    "action": "remove-from-favorites",
                    "icon": "star",
                    "enabled": true
                });
            } else {
                newModel.push({
                    "label": "Добавить в избранное",
                    "action": "add-to-favorites",
                    "icon": "star-filled",
                    "enabled": true
                });
            }
            
            model = newModel;
        }
        
        function openForApp(app, mouseX, mouseY) {
            currentApp = app;
            updateMenuModel();
            
            var anchor = Qt.createQmlObject(`
                import QtQuick
                Item {
                    width: 1
                    height: 1
                    x: ${mouseX}
                    y: ${mouseY}
                }
            `, root, "contextMenuAnchor");
            
            openAtItem(anchor, null);
            
            appContextMenu.closed.connect(function() {
                if (anchor) {
                    anchor.destroy();
                }
                appContextMenu.closed.disconnect(arguments.callee);
            });
        }
        
        function close() {
            visible = false;
            currentApp = null;
        }
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
            spacing: Style.marginL

            // Панель вкладок
            Rectangle {
                id: tabsContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: Color.mSurfaceVariant
                radius: Style.radiusM
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    spacing: 0

                    // Вкладка "Избранное"
                    Rectangle {
                        id: favoritesTab
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Style.radiusS
                        color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 1 ? Color.mPrimary : "transparent"
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (pluginApi && pluginApi.mainInstance) {
                                    pluginApi.mainInstance.currentTab = 1;
                                    pluginApi.mainInstance.selectedIndex = 0;
                                    pluginApi.mainInstance.searchQuery = "";
                                    searchInput.text = "";
                                    pluginApi.mainInstance.allApps = pluginApi.mainInstance.getAllApps();
                                }
                            }
                        }
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Style.marginS
                            
                            NIcon {
                                icon: "star"
                                color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 1 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                width: 16
                                height: 16
                            }
                            
                            NText {
                                text: "Избранное"
                                color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 1 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                font.pointSize: Style.fontSizeS
                                font.weight: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 1 ? Font.Bold : Font.Normal
                            }
                            
                            // Счетчик избранных
                            Rectangle {
                                visible: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.favoriteApps.length > 0
                                width: 16
                                height: 16
                                radius: 8
                                color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 1 ? Color.mOnPrimary : Color.mPrimary
                                
                                NText {
                                    anchors.centerIn: parent
                                    text: pluginApi && pluginApi.mainInstance ? pluginApi.mainInstance.favoriteApps.length : 0
                                    color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 1 ? Color.mPrimary : Color.mOnPrimary
                                    font.pointSize: Style.fontSizeXS
                                    font.bold: true
                                }
                            }
                        }
                    }
                    
                    // Вкладка "Все приложения"
                    Rectangle {
                        id: allAppsTab
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Style.radiusS
                        color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 0 ? Color.mPrimary : "transparent"
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (pluginApi && pluginApi.mainInstance) {
                                    pluginApi.mainInstance.currentTab = 0;
                                    pluginApi.mainInstance.selectedIndex = 0;
                                    pluginApi.mainInstance.searchQuery = "";
                                    searchInput.text = "";
                                    pluginApi.mainInstance.allApps = pluginApi.mainInstance.getAllApps();
                                }
                            }
                        }
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Style.marginS
                            
                            NIcon {
                                icon: "apps"
                                color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 0 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                width: 16
                                height: 16
                            }
                            
                            NText {
                                text: "Все"
                                color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 0 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                font.pointSize: Style.fontSizeS
                                font.weight: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 0 ? Font.Bold : Font.Normal
                            }
                        }
                    }
                }
            }

            NTextInput {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.currentTab === 0 ? 
                                "Поиск приложений..." : "Поиск в избранном..."
                inputIconName: "search"
                
                Keys.onReturnPressed: {
                    if (pluginApi && pluginApi.mainInstance) {
                        var filteredApps = pluginApi.mainInstance.getFilteredApps();
                        if (filteredApps.length > 0) {
                            pluginApi.mainInstance.launchApp(filteredApps[pluginApi.mainInstance.selectedIndex]);
                        }
                    }
                }
                
                Keys.onPressed: function(event) {
                    if (!pluginApi || !pluginApi.mainInstance) return;
                    
                    var filteredApps = pluginApi.mainInstance.getFilteredApps();
                    
                    if (event.key === Qt.Key_Escape) {
                        if (pluginApi) {
                            pluginApi.closePanel();
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                        pluginApi.mainInstance.selectedIndex = Math.min(pluginApi.mainInstance.selectedIndex + 1, filteredApps.length - 1);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(pluginApi.mainInstance.selectedIndex, ListView.Contain);
                        }
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                        pluginApi.mainInstance.selectedIndex = Math.max(pluginApi.mainInstance.selectedIndex - 1, 0);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(pluginApi.mainInstance.selectedIndex, ListView.Contain);
                        }
                    } else if (event.key === Qt.Key_PageDown) {
                        pluginApi.mainInstance.selectedIndex = Math.min(pluginApi.mainInstance.selectedIndex + 5, filteredApps.length - 1);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(pluginApi.mainInstance.selectedIndex, ListView.Contain);
                        }
                    } else if (event.key === Qt.Key_PageUp) {
                        pluginApi.mainInstance.selectedIndex = Math.max(pluginApi.mainInstance.selectedIndex - 5, 0);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(pluginApi.mainInstance.selectedIndex, ListView.Contain);
                        }
                    }
                }
                
                onTextChanged: {
                    if (pluginApi && pluginApi.mainInstance) {
                        pluginApi.mainInstance.searchQuery = text;
                        pluginApi.mainInstance.selectedIndex = 0;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtBeginning();
                        }
                    }
                }
                
                Component.onCompleted: {
                    if (pluginApi && pluginApi.mainInstance) {
                        pluginApi.mainInstance.initializePanel();
                        pluginApi.mainInstance.allApps = pluginApi.mainInstance.getAllApps();
                    }
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
                    model: pluginApi && pluginApi.mainInstance ? pluginApi.mainInstance.getFilteredApps() : []
                    spacing: 2
                    clip: true
                    
                    delegate: Rectangle {
                        id: appDelegate
                        width: appListView.width
                        height: itemHeight
                        color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.selectedIndex === index ? Color.mPrimary : "transparent"
                        radius: Style.radiusS

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onEntered: {
                                if (pluginApi && pluginApi.mainInstance) {
                                    pluginApi.mainInstance.selectedIndex = index;
                                }
                            }
                            onClicked: function(mouse) {
                                if (pluginApi && pluginApi.mainInstance) {
                                    pluginApi.mainInstance.selectedIndex = index;
                                    if (mouse.button === Qt.LeftButton) {
                                        pluginApi.mainInstance.launchApp(modelData);
                                    } else if (mouse.button === Qt.RightButton) {
                                        var appDelegatePos = appDelegate.mapToItem(root, 0, 0);
                                        var clickX = mouse.x + appDelegatePos.x;
                                        var clickY = mouse.y + appDelegatePos.y;
                                        appContextMenu.openForApp(modelData, clickX, clickY);
                                    }
                                }
                            }
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
                                color: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.selectedIndex === index ? Color.mOnPrimary : Color.mOnSurface
                                font.pointSize: Style.fontSizeS
                                font.weight: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.selectedIndex === index ? Font.Bold : Font.Normal
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Color.mPrimary
                                opacity: pluginApi && pluginApi.mainInstance && pluginApi.mainInstance.selectedIndex === index ? 1 : 0
                                
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
                    visible: {
                        if (!pluginApi || !pluginApi.mainInstance) return true;
                        var filteredApps = pluginApi.mainInstance.getFilteredApps();
                        return filteredApps.length === 0;
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Style.marginM
                        
                        NIcon {
                            icon: {
                                if (!pluginApi || !pluginApi.mainInstance) return "apps";
                                var searchQuery = pluginApi.mainInstance.searchQuery;
                                var currentTab = pluginApi.mainInstance.currentTab;
                                var favoriteApps = pluginApi.mainInstance.favoriteApps || [];
                                
                                if (searchQuery !== "") {
                                    return "search-off";
                                } else if (currentTab === 1) {
                                    return favoriteApps.length === 0 ? "star" : "search";
                                } else {
                                    return "apps";
                                }
                            }
                            color: Color.mOnSurfaceVariant
                            width: 64
                            height: 64
                            opacity: 0.5
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        NText {
                            text: {
                                if (!pluginApi || !pluginApi.mainInstance) return "Нет данных";
                                var searchQuery = pluginApi.mainInstance.searchQuery;
                                var currentTab = pluginApi.mainInstance.currentTab;
                                var favoriteApps = pluginApi.mainInstance.favoriteApps || [];
                                
                                if (searchQuery !== "") {
                                    return "Ничего не найдено";
                                } else if (currentTab === 1) {
                                    return favoriteApps.length === 0 ? "Избранное пусто" : "Начните вводить название";
                                } else {
                                    return "Начните вводить название приложения";
                                }
                            }
                            color: Color.mOnSurfaceVariant
                            font.pointSize: Style.fontSizeM
                            font.weight: Font.Medium
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        NText {
                            text: {
                                if (!pluginApi || !pluginApi.mainInstance) return "Ожидание данных...";
                                var searchQuery = pluginApi.mainInstance.searchQuery;
                                var currentTab = pluginApi.mainInstance.currentTab;
                                var favoriteApps = pluginApi.mainInstance.favoriteApps || [];
                                
                                if (searchQuery !== "") {
                                    return "Попробуйте другой запрос";
                                } else if (currentTab === 1) {
                                    return favoriteApps.length === 0 ? "Добавьте приложения в избранное" : "Используйте поле поиска";
                                } else {
                                    return "Используйте поле поиска выше";
                                }
                            }
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
                
                visible: {
                    if (!pluginApi || !pluginApi.mainInstance) return false;
                    // Только на вкладке "Все приложения"
                    return pluginApi.mainInstance.currentTab === 0;
                }

                NText {
                    anchors.left: parent.left
                    anchors.rightMargin: Style.marginM
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!pluginApi || !pluginApi.mainInstance) return "";
                        var currentTab = pluginApi.mainInstance.currentTab;
                        var total = currentTab === 0 ? 
                                   (pluginApi.mainInstance.allApps ? pluginApi.mainInstance.allApps.length : 0) : 
                                   (pluginApi.mainInstance.favoriteApps ? pluginApi.mainInstance.favoriteApps.length : 0);
                        var filteredApps = pluginApi.mainInstance.getFilteredApps();
                        // var showing = filteredApps.length;
                        return  "Всего: " + total + " приложений";
                    }
                    color: Color.mOnSurfaceVariant
                    font.pointSize: Style.fontSizeS
                    opacity: 0.7
                }
            }
        }
    }
}