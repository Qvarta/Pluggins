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
    property var favoriteApps: []
    property string searchQuery: ""
    property int selectedIndex: 0
    property int currentTab: 0 // 0 - Все приложения, 1 - Избранное

    anchors.fill: parent

    property var filteredApps: {
        var query = searchQuery.toLowerCase().trim();
        var appsToFilter = currentTab === 0 ? allApps : favoriteApps;
        
        if (query === "") {
            return appsToFilter.slice(0, 30);
        }
        
        return appsToFilter.filter(function(app) {
            var name = (app.name || "").toLowerCase();
            var comment = (app.comment || "").toLowerCase();
            return name.includes(query) || comment.includes(query);
        }).slice(0, 30);
    }
    
    Component.onCompleted: {
        loadApps();
        loadFavoriteApps();
    }
    
    function loadApps() {
        allApps = getAllApps();
    }
    
    function loadFavoriteApps() {
        // TODO: Загрузка избранных приложений из конфигурации
        // Пока оставляем пустым
        favoriteApps = [];
    }
    
    function addToFavorites(app) {
        // TODO: Реализовать добавление в избранное
        console.log("Добавить в избранное:", app.name || app.id);
    }
    
    function removeFromFavorites(appId) {
        // TODO: Реализовать удаление из избранного
        console.log("Удалить из избранного:", appId);
    }
    
    function isFavorite(appId) {
        return favoriteApps.some(function(app) {
            return app.id === appId;
        });
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

    // Контекстное меню для приложений
    NPopupContextMenu {
        id: appContextMenu
        itemHeight: 36
        minWidth: 160
        
        property var currentApp: null
        
        model: [
            {
                "label": "Запустить",
                "action": "launch",
                "icon": "player-play",
                "enabled": currentApp !== null
            },
            {
                "label": "Добавить в избранное",
                "action": "add-to-favorites",
                "icon": "star-filled",
                "enabled": currentApp !== null
            },
            {
                "label": "Удалить из избранного",
                "action": "remove-from-favorites",
                "icon": "star",
                "enabled": currentApp !== null && isFavorite(currentApp.id),
                "visible": currentApp !== null && isFavorite(currentApp.id)
            }
        ]
        
        onTriggered: function(action, item) {
            if (currentApp) {
                if (action === "launch") {
                    launchApp(currentApp);
                } else if (action === "add-to-favorites") {
                    addToFavorites(currentApp);
                    // Обновляем модель меню после добавления
                    Qt.callLater(updateMenuModel);
                } else if (action === "remove-from-favorites") {
                    removeFromFavorites(currentApp.id);
                    // Обновляем модель меню после удаления
                    Qt.callLater(updateMenuModel);
                    // Если мы на вкладке избранного, обновляем список
                    if (currentTab === 1) {
                        filteredApps = filteredApps.filter(function(app) {
                            return app.id !== currentApp.id;
                        });
                    }
                }
            }
            close();
        }
        
        function updateMenuModel() {
            // Обновляем модель для отображения правильного состояния кнопок
            var newModel = [
                {
                    "label": "Запустить",
                    "action": "launch",
                    "icon": "player-play",
                    "enabled": currentApp !== null
                }
            ];
            
            if (currentApp && isFavorite(currentApp.id)) {
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
                    "enabled": currentApp !== null
                });
            }
            
            model = newModel;
        }
        
        function openForApp(app, mouseX, mouseY) {
            currentApp = app;
            updateMenuModel();
            
            // Создаем временный элемент для позиционирования
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
            
            // Удаляем временный элемент после закрытия меню
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
            spacing: Style.marginS

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
                    
                    // Вкладка "Все приложения"
                    Rectangle {
                        id: allAppsTab
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Style.radiusS
                        color: currentTab === 0 ? Color.mPrimary : "transparent"
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentTab = 0;
                                selectedIndex = 0;
                                searchQuery = "";
                                searchInput.text = "";
                            }
                        }
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Style.marginS
                            
                            NIcon {
                                icon: "apps"
                                color: currentTab === 0 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                width: 16
                                height: 16
                            }
                            
                            NText {
                                text: "Все"
                                color: currentTab === 0 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                font.pointSize: Style.fontSizeS
                                font.weight: currentTab === 0 ? Font.Bold : Font.Normal
                            }
                        }
                    }
                    
                    // Вкладка "Избранное"
                    Rectangle {
                        id: favoritesTab
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Style.radiusS
                        color: currentTab === 1 ? Color.mPrimary : "transparent"
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentTab = 1;
                                selectedIndex = 0;
                                searchQuery = "";
                                searchInput.text = "";
                            }
                        }
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Style.marginS
                            
                            NIcon {
                                icon: "star"
                                color: currentTab === 1 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                width: 16
                                height: 16
                            }
                            
                            NText {
                                text: "Избранное"
                                color: currentTab === 1 ? Color.mOnPrimary : Color.mOnSurfaceVariant
                                font.pointSize: Style.fontSizeS
                                font.weight: currentTab === 1 ? Font.Bold : Font.Normal
                            }
                            
                            // Счетчик избранных
                            Rectangle {
                                visible: favoriteApps.length > 0
                                width: 16
                                height: 16
                                radius: 8
                                color: currentTab === 1 ? Color.mOnPrimary : Color.mPrimary
                                
                                NText {
                                    anchors.centerIn: parent
                                    text: favoriteApps.length
                                    color: currentTab === 1 ? Color.mPrimary : Color.mOnPrimary
                                    font.pointSize: Style.fontSizeXS
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }

            NTextInput {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: currentTab === 0 ? "Поиск приложений..." : "Поиск в избранном..."
                inputIconName: "search"
                
                Keys.onReturnPressed: {
                    if (filteredApps.length > 0) {
                        launchApp(filteredApps[selectedIndex]);
                    }
                }
                
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Escape) {
                        if (pluginApi) {
                            pluginApi.closePanel();
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                        selectedIndex = Math.min(selectedIndex + 1, filteredApps.length - 1);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(selectedIndex, ListView.Contain);
                        }
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                        selectedIndex = Math.max(selectedIndex - 1, 0);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(selectedIndex, ListView.Contain);
                        }
                    } else if (event.key === Qt.Key_PageDown) {
                        selectedIndex = Math.min(selectedIndex + 5, filteredApps.length - 1);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(selectedIndex, ListView.Contain);
                        }
                    } else if (event.key === Qt.Key_PageUp) {
                        selectedIndex = Math.max(selectedIndex - 5, 0);
                        event.accepted = true;
                        if (appListView.contentHeight > appListView.height) {
                            appListView.positionViewAtIndex(selectedIndex, ListView.Contain);
                        }
                    }
                }
                
                onTextChanged: {
                    searchQuery = text;
                    selectedIndex = 0;
                    if (appListView.contentHeight > appListView.height) {
                        appListView.positionViewAtBeginning();
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
                    model: filteredApps
                    spacing: 2
                    clip: true
                    
                    delegate: Rectangle {
                        id: appDelegate
                        width: appListView.width
                        height: itemHeight
                        color: selectedIndex === index ? Color.mPrimary : "transparent"
                        radius: Style.radiusS


                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onEntered: {
                                selectedIndex = index;
                            }
                            onClicked: function(mouse) {
                                selectedIndex = index;
                                if (mouse.button === Qt.LeftButton) {
                                    launchApp(modelData);
                                } else if (mouse.button === Qt.RightButton) {
                                    // Открываем контекстное меню для этого приложения
                                    var appDelegatePos = appDelegate.mapToItem(root, 0, 0);
                                    var clickX = mouse.x + appDelegatePos.x;
                                    var clickY = mouse.y + appDelegatePos.y;
                                    appContextMenu.openForApp(modelData, clickX, clickY);
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
                            icon: {
                                if (searchQuery !== "") {
                                    return "search-off";
                                } else if (currentTab === 1) {
                                    return favoriteApps.length === 0 ? "star-filled" : "search";
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
                                if (searchQuery !== "") {
                                    return "Попробуйте другой запрос";
                                } else if (currentTab === 1) {
                                    return favoriteApps.length === 0 ? "Добавьте приложения в избранное через контекстное меню" : "Используйте поле поиска выше";
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
                
                visible: filteredApps.length > 0

                NText {
                    anchors.centerIn: parent
                    text: {
                        var total = currentTab === 0 ? allApps.length : favoriteApps.length;
                        return filteredApps.length + " из " + total + " приложений";
                    }
                    color: Color.mOnSurfaceVariant
                    font.pointSize: Style.fontSizeS
                    opacity: 0.7
                }
            }
        }
    }
}