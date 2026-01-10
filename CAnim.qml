import QtQuick

ColorAnimation {
    duration: 100
    easing.type: Easing.BezierSpline
    easing.bezierCurve: [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]
}
