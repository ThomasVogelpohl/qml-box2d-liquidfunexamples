import QtQuick 2.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Particles 2.0
import Box2DStatic 2.0
import "../shared"

Item {
    id: screen
    width: 800
    height: 600
    focus: true

    property real particleRadius: (screen.width * 0.003)
    property Body pressedBody: null
    property int particleCount: 0
    property var particleObjects: []


    Component {
        id: ballComponent

        Rectangle {
            radius: particleRadius
            border.color: "darkblue"
            border.width: 1
            color: "deepskyblue" //"#EFEFEF"
            width: (particleRadius * 2)
            height: width
        }
    }


    function randomColor() {
        return Qt.rgba(Math.random(), Math.random(), Math.random(), 1);
    }

    World {
        id: physicsWorld

        timeStep: (1.0 / 60.0)
        enableContactEvents: false
        // positionIterations: 5
        // velocityIterations: 8
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onPressed: {
            if (screen.pressedBody != null) {
                mouseJoint.maxForce = screen.pressedBody.getMass() * 500;
                mouseJoint.target = Qt.point(mouseX, mouseY);
                mouseJoint.bodyB = screen.pressedBody;
            }
        }

        onPositionChanged: {
            mouseJoint.target = Qt.point(mouseX, mouseY);
        }

        onReleased: {
            mouseJoint.bodyB = null;
            screen.pressedBody = null;
        }
    }

    Body {
        id: mouseJointAnchor
        world: physicsWorld
    }

    MouseJoint {
        id: mouseJoint
        bodyA: mouseJointAnchor
        dampingRatio: 0.8
        maxForce: 100
    }


    Rectangle {
        id: movableRect
        x: (waveBox.x + 50)
        y: (waveBox.y + 50)

        width: (waveBox.width / 10)
        height: (waveBox.width / 10)
        color: "#efbf78" //screen.randomColor()

        Body {
            id: rectangleBody

            target: movableRect
            world: physicsWorld
            bodyType: Body.Dynamic

            Box {
                width: movableRect.width
                height: movableRect.height

                density: 0.5
                restitution: 0.5
                friction: 0.5
            }
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onPressed: {
                mouse.accepted = false;
                screen.pressedBody = rectangleBody;
            }
        }
    }

    Item {
        id: waveBox
        x: (screen.width / 2) - (waveBox.width / 2)
        y: (screen.height / 2) - (waveBox.height / 2)

        width: (screen.width / 2)
        height:(screen.height / 2)

        transformOrigin: Item.Center

        property int wallThickness: 20

        SequentialAnimation {
            id: waveAction
            running: true
            loops: Animation.Infinite
            
            PropertyAnimation { id: animation1; target: waveBox; property: "rotation"; easing.type: Easing.OutQuad; from: 0; to: 15; duration: 600; }
            PropertyAnimation { id: animation2; target: waveBox; property: "rotation"; easing.type: Easing.InOutQuad; from: 15; to: -15; duration: 1200 }
            PropertyAnimation { id: animation3; target: waveBox; property: "rotation"; easing.type: Easing.InQuad; from: -15; to: 0; duration: 600; }
        }

        Body {
            id: waveBoxBody

            target: waveBox
            bodyType: Body.Kinematic

            Box {
                id: left
                x: leftRect.x
                y: leftRect.y

                width: waveBox.wallThickness
                height: waveBox.height
            }

            Box {
                id: right
                x: rightRect.x
                y: rightRect.y

                width: waveBox.wallThickness
                height: waveBox.height
            }

            Box {
                id: top
                x: topRect.x
                y: topRect.y

                width: waveBox.width
                height: waveBox.wallThickness
            }

            Box {
                id: bottom
                x: bottomRect.x
                y: bottomRect.y

                width: waveBox.width
                height: waveBox.wallThickness
            }
        }

        Rectangle {
            id: leftRect
            anchors.left: parent.left

            width: waveBox.wallThickness
            height: waveBox.height
            border.color: "black"
            border.width: 2
        }

        Rectangle {
            id: rightRect
            anchors.right: parent.right

            width: waveBox.wallThickness
            height: waveBox.height
            border.color: "black"
            border.width: 2
        }

        Rectangle {
            id: topRect
            anchors.top: parent.top

            width: waveBox.width
            height: waveBox.wallThickness
            border.color: "black"
            border.width: 2
        }

        Rectangle {
            id: bottomRect
            anchors.bottom: parent.bottom

            width: waveBox.width
            height: waveBox.wallThickness
            border.color: "black"
            border.width: 2
        }
    }

    Box2DParticleSystem {
        id: box2DParticleSystem
        particleRadius: screen.particleRadius / physicsWorld.pixelsPerMeter
        world: physicsWorld
    }


    Rectangle {
        id: animateButton
        x: 30
        y: 30
        width: 170
        height: 30
        Text {
            text: (waveAction.paused === true) ? "Paused" : "Animate"
            anchors.centerIn: parent
        }
        color: "#DEDEDE"
        border.color: "#999"
        radius: 5
        MouseArea {
            anchors.fill: parent
            onClicked: {
                waveAction.paused = !waveAction.paused;
            }
        }
    }


    Rectangle {
        id: numParticles
        x: 30
        y: 80
        width: 170
        height: 30
        Text {
            text: "Particles: " + particleCount
            anchors.centerIn: parent
        }
        color: "transparent"
        border.color: "black"
        radius: 5
    }

    DebugDraw {
        id: debugDraw
        world: physicsWorld
        anchors.fill: parent
        opacity: 0.7
        visible: false
        flags: DebugDraw.Everything
    }


    function createParticleRectangle (x, y, width, height, particleDistance) {
        var pixelsPerMeter = physicsWorld.pixelsPerMeter
        particleCount = 0
        for(var i = x; i < x + width; i += particleDistance)     {
            for(var j = y; j < y + height; j += particleDistance)     {
                var newBall = ballComponent.createObject(screen);

                // console.log("newBall: " + newBall + " - i: " + i + " - j: " + -j)
                newBall.x = i
                newBall.y = j

                box2DParticleSystem.addParticle(i / pixelsPerMeter, -(j) / pixelsPerMeter, newBall);
                particleObjects.push(newBall)
                particleCount += 1
            }
        }
        box2DParticleSystem.particleCreationDone(true);
    }

    Component.onCompleted: {
        createParticleRectangle ((waveBox.x + waveBox.wallThickness), (waveBox.y + waveBox.wallThickness), (waveBox.width - (2 * waveBox.wallThickness)), (waveBox.height / 2), (particleRadius*2));
    }

    Component.onDestruction: {
        for (var particleCount = 0; particleCount < particleObjects.length; particleCount++){
            particleObjects[particleCount].destroy()
        }
    }
}
