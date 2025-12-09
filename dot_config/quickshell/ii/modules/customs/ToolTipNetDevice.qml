import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts
import qs.modules.common.functions
import qs.modules.bar
import QtQuick.Controls
import Quickshell
import Quickshell.Io

StyledPopup {
    id: root

    property string displayWifiText: Network.networkName ? "󰖩 - " +  Network.networkName : "󰖪 - Network Disconnected"
    property string displayBluetoothText: Bluetooth.getBluetoothDevices() != "" ? "󰂯 - " + Bluetooth.getBluetoothDevices() : "󰂯 - No devices connected";

    ColumnLayout {
        id: columnLayout
        spacing: 4
        anchors.fill: parent
        anchors.margins: 12

        // Header
        RowLayout {
            id: header
            Layout.fillWidth: true
            spacing: 5
            Layout.minimumWidth: 250

            StyledText {
                id: headerText

                text: "Connections / Devices"
                font {
                    weight: Font.Medium
                    pixelSize: Appearance.font.pixelSize.normal
                }
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        RowLayout {
            id: customToolTipRowLayoutWifi
            Layout.fillWidth: true
            layoutDirection: Qt.RightToLeft
            spacing: 5

            StyledText {
                text: root.displayWifiText
                font {
                    family: "JetBrainsMono Nerd Font"
                }
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        RowLayout {
            id: customToolTipRowLayoutBluetooth
            Layout.fillWidth: true
            layoutDirection: Qt.RightToLeft
            spacing: 5

            StyledText {

                text: root.displayBluetoothText
                font {
                    family: "JetBrainsMono Nerd Font"
                }
                color: Appearance.colors.colOnSurfaceVariant
            }
        }
    }
}
