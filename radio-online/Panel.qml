import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null
    
    readonly property var geometryPlaceholder: panelContainer
    property real contentPreferredWidth: 220 * Style.uiScaleRatio
    property real contentPreferredHeight: 300 * Style.uiScaleRatio
    readonly property bool allowAttach: true

    anchors.fill: parent

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: Color.transparent

        ColumnLayout {
            anchors {
                fill: parent
                margins: Style.marginM
            }
            spacing: Style.marginM

            NText {
                text: "Radio Stations"
                font.pointSize: Style.fontSizeM
                font.weight: Font.Medium
                color: Color.mOnSurface
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: Color.mSurface
                radius: Style.radiusS
                visible: pluginApi && pluginApi.mainInstance && 
                        pluginApi.mainInstance.currentPlayingProcessState === "start" && 
                        pluginApi.mainInstance.currentPlayingStation !== ""

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginS

                    NText {
                        text: "▶ Now playing:"
                        color: Color.mPrimary
                        font.pointSize: Style.fontSizeS
                    }

                    NText {
                        text: pluginApi && pluginApi.mainInstance ? 
                              pluginApi.mainInstance.currentPlayingStation || "" : ""
                        color: Color.mOnSurface
                        font.pointSize: Style.fontSizeS
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: stopButton.containsPress ? Qt.darker(Color.mError, 1.2) : 
                              stopButton.containsMouse ? Qt.darker(Color.mError, 1.1) : 
                              Color.mError

                        NText {
                            anchors.centerIn: parent
                            text: "⏹"
                            color: Color.mOnError
                            font.pointSize: Style.fontSizeXS
                        }

                        MouseArea {
                            id: stopButton
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (pluginApi && pluginApi.mainInstance) {
                                    pluginApi.mainInstance.stopPlayback();
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Color.mSurfaceVariant
                radius: Style.radiusM

                Flickable {
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    contentWidth: width
                    contentHeight: column.implicitHeight
                    clip: true

                    Column {
                        id: column
                        width: parent.width
                        spacing: 2

                        Repeater {
                            model: pluginApi && pluginApi.mainInstance ? 
                                   pluginApi.mainInstance.getStations() : []

                            Rectangle {
                                id: stationButton
                                width: column.width
                                height: stationText.implicitHeight + Style.marginS * 2
                                color: {
                                    var isPlaying = (pluginApi && pluginApi.mainInstance &&
                                                    pluginApi.mainInstance.currentPlayingProcessState === "start" &&
                                                    pluginApi.mainInstance.currentPlayingStation === modelData.name);
                                    
                                    if (isPlaying) {
                                        return Color.mPrimaryContainer || "#E8DEF8";
                                    } else if (mouseArea.containsPress) {
                                        return Qt.lighter(Color.mSurfaceVariant, 1.1);
                                    } else if (mouseArea.containsMouse) {
                                        return Qt.lighter(Color.mSurfaceVariant, 1.05);
                                    } else {
                                        return "transparent";
                                    }
                                }
                                radius: Style.radiusS

                                property string stationName: modelData.name
                                property string stationUrl: modelData.url

                                NText {
                                    id: stationText
                                    anchors.fill: parent
                                    anchors.margins: Style.marginS
                                    text: modelData.name
                                    color: {
                                        var isPlaying = (pluginApi && pluginApi.mainInstance &&
                                                        pluginApi.mainInstance.currentPlayingProcessState === "start" &&
                                                        pluginApi.mainInstance.currentPlayingStation === modelData.name);
                                        
                                        return isPlaying ? 
                                               (Color.mOnPrimaryContainer || "#1D192B") : 
                                               Color.mPrimary;
                                    }
                                    font.pointSize: Style.fontSizeS
                                    verticalAlignment: Text.AlignVCenter
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        if (pluginApi && pluginApi.mainInstance) {
                                            var main = pluginApi.mainInstance;
                                            var isCurrentlyPlaying = (main.currentPlayingProcessState === "start" &&
                                                                     main.currentPlayingStation === stationName);
                                            
                                            if (isCurrentlyPlaying) {
                                                main.stopPlayback();
                                            } else {
                                                main.playStation(stationName, stationUrl);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            width: column.width
                            height: 50
                            visible: column.children.length === 1

                            NText {
                                anchors.centerIn: parent
                                text: "No stations loaded"
                                color: Color.mOnSurfaceVariant
                                font.pointSize: Style.fontSizeS
                            }
                        }
                    }
                }
            }
        }
    }
}