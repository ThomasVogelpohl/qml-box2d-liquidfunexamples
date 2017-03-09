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
    property int overallParticleCount: 0


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

    World {
        id: physicsWorld

        timeStep: (1.0 / 60.0)
        enableContactEvents: false
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
        x: (waveBox.x + (waveBox.width / 2))
        y: (waveBox.y - 100)

        width: (waveBox.width / 10)
        height: (waveBox.width / 10)
        color: "#efbf78"

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
        id: numParticles
        x: 30
        y: 80
        width: 170
        height: 30
        Text {
            text: "Particles: " + overallParticleCount
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


    function createParticleGroupRectangle (x, y, width, height, particleDistance) {
        var pixelsPerMeter = physicsWorld.pixelsPerMeter
        var particleArray = []


        box2DParticleSystem.addParticleGroup((x/pixelsPerMeter), ((-y)/pixelsPerMeter), ((width)/pixelsPerMeter), ((height)/pixelsPerMeter), particleArray)
        overallParticleCount = box2DParticleSystem.particleCount()
        var coordinates = box2DParticleSystem.particleCoordinates();

        for( var particleCount = 0; particleCount < overallParticleCount; particleCount++) {
            var newBall = ballComponent.createObject(screen);

            newBall.x = coordinates[particleCount*2] * pixelsPerMeter
            newBall.y = coordinates[particleCount*2 + 1] * pixelsPerMeter * -1

            box2DParticleSystem.registerQmlObjectWithParticle(particleCount, newBall);
        }

        box2DParticleSystem.particleCreationDone(true);
    }


    Component.onCompleted: {
        createParticleGroupRectangle ((waveBox.x + waveBox.wallThickness), (waveBox.y), (waveBox.width - (2 * waveBox.wallThickness)), (waveBox.height / 2), (particleRadius*2));

    }
}
