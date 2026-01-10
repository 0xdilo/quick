import QtQuick

NumberAnimation {
    duration: 150
    easing.type: Easing.BezierSpline
    easing.bezierCurve: [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]
}
