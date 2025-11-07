import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.common
import qs.modules.bar
import qs.modules.common.widgets
import qs.services
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
    id: powerProfile
    implicitWidth: 55
    implicitHeight: Appearance.sizes.barHeight * 0.55
    color: batteryPercent > 50 ? "#D5E4F7" : batteryPercent < 21 ? "red" : "orange"

    radius: 10
    border.color: "#000"
    border.width: 1

    property var icons: {
        "power-saver": "󰌪 ",
        "balanced": "  ",
        "performance": "󱎓 "
    }

    property string profile: ""
    property string displayText: (icons[profile] || "❓") + batteryPercent + "%"

    property real batteryPercent: UPower.displayDevice.percentage * 100

    Component.onCompleted: {
        profileProcess.running = true
        batteryProcess.running = true
    }

    // Update power profile
    Process {
        id: profileProcess
        command: ["bash", "-c", "powerprofilesctl get"]
         stdout: StdioCollector {
            onStreamFinished: {
                powerProfile.profile = text.trim()
            }
        }
    }

    // Update battery
    Process {
        id: batteryProcess
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity"]

        onExited: {
            powerProfile.batteryPercent = parseInt(stdout.trim())
        }
    }

    // Refresh every 5s
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            profileProcess.running = true
            batteryProcess.running = true
        }
    }

    Process {
        id: cycleProfileProcess
        command: ["sh", "-c", "~/.config/hyprpanel/scripts/cycle-power-profile.sh"]
        stdout: StdioCollector {
            id: cycleStdout
            onStreamFinished: {
                powerProfile.profile = text.trim()
            }
        }
    }

    // UI
    MouseArea {
        id: powerProfileArea
        anchors.fill: parent
        width: label.width + 30
        height: Appearance.sizes.barHeight
        hoverEnabled: true  // Important !

        onClicked: cycleProfileProcess.running = true
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                Process.exec("brightnessctl", ["set", "+5%"])
            } else {
                Process.exec("brightnessctl", ["set", "5%-"])
            }
        }

        Text {
            id: label
            font.family: "JetBrainsMono Nerd Font"
            font.pointSize: 10
            font.weight: Font.DemiBold
            text: powerProfile.displayText
            color: "black"
            anchors.centerIn: parent
        }

        BatteryPopup {
            id: batteryPopup
            hoverTarget: powerProfileArea
        }
    }
}
