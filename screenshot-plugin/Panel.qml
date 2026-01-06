import QtQuick
import qs.Widgets
import qs.Commons

Item {
    id: panelRoot
    property var pluginApi: null
    
    // Указываем размеры панели (компактный вариант)
    property int contentPreferredWidth: 300 * Style.uiScaleRatio
    property int contentPreferredHeight: 120 * Style.uiScaleRatio
    
    // Фон панели
    Rectangle {
        anchors.fill: parent
        color: "#CC2D3748"
        radius: 12 * Style.uiScaleRatio
        border {
            width: 1
            color: Color.mOutline
        }
    }
    
    // Контент панели
    Column {
        anchors.centerIn: parent
        spacing: 12 * Style.uiScaleRatio
        
        NText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Сделать скриншот"
            color: Color.mOnSurface
            pointSize: Style.fontSizeL
            font.weight: Font.Medium
        }
        
        Row {
            spacing: 16 * Style.uiScaleRatio
            
            NIconButton {
                icon: "screenshot"
                tooltipText: "Весь экран"
                onClicked: takeAndClose("output")
            }
            
            NIconButton {
                icon: "crop"
                tooltipText: "Выбрать область"
                onClicked: takeAndClose("region")
            }
            
            NIconButton {
                icon: "window"
                tooltipText: "Активное окно"
                onClicked: takeAndClose("window")
            }
        }
    }
    
    // Обработка клика вне панели
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: {
            // Позволяем клику пройти к элементам внутри
            mouse.accepted = false;
        }
    }
    
    // Функция создания скриншота и закрытия панели
    function takeAndClose(mode) {
        if (pluginApi && pluginApi.root && typeof pluginApi.root.takeScreenshot === 'function') {
            pluginApi.root.takeScreenshot(mode);
        }
        
        // Уведомляем Main.qml о закрытии панели
        closePanel();
    }
    
    // Функция закрытия панели
    function closePanel() {
        if (pluginApi && typeof pluginApi.closePanel === 'function') {
            pluginApi.closePanel(0);
        }
    }
    
    // Закрытие по Escape
    Keys.onEscapePressed: closePanel()
}