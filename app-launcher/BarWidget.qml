import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen

    readonly property bool isBarVertical: Settings.data.bar.position === "left" || Settings.data.bar.position === "right"
    readonly property string displayMode: "auto"

    implicitWidth: pill.width
    implicitHeight: pill.height

    BarPill {
        id: pill

        screen: root.screen
        oppositeDirection: BarService.getPillDirection(root)
        icon: "123"
        text: "text"
        autoHide: false
        forceOpen: true
        forceClose: false
        tooltipText: "App"
        
        onClicked: {
            pluginApi.openPanel(root.screen,this);
        }
    }
}