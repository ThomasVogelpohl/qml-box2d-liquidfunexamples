import QtQuick 2.2
import Box2DStatic 2.0
import QtQuick.Particles 2.0

import "../shared"

Rectangle {
    id: screen
    width: 800
    height: 500

    property int maxNumOfParticles: 150000
    property real particleRadius: 2
    property Body pressedBody: null

    function randomColor() {
        return Qt.rgba(Math.random(), Math.random(), Math.random(), Math.random());
    }

    World {
        id: physicsWorld
    }

    ScreenBoundaries {
    }






    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onPressed: {
            if (pressedBody != null) {
                mouseJoint.maxForce = pressedBody.getMass() * 500;
                mouseJoint.target = Qt.point(mouseX, mouseY);
                mouseJoint.bodyB = pressedBody;
            }
        }

        onPositionChanged: {
            mouseJoint.target = Qt.point(mouseX, mouseY);
        }

        onReleased: {
            mouseJoint.bodyB = null;
            pressedBody = null;
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
        x: (parent.width/2)
        y: (parent.height/2)

        width: 50
        height: 50
        color: "red"
        border.color: randomColor()

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
                pressedBody = rectangleBody;
            }
        }
    }

    Item {
        id: waveBox
        x: 150
        y: 150

        width: 500
        height: 200

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

    Component {
        id: blueBall
        Rectangle {
            width: screen.particleRadius * 2
            height: screen.particleRadius * 2
            radius: screen.particleRadius
            border.color: "#550000ff"
            border.width: 1
            color: "transparent"
        }
    }

    ParticleSystem {
        id: particleSystem
        ItemParticle {
            fade: false
            delegate: blueBall
        }
    }

    Emitter {
        id: emitter
        anchors.centerIn: parent
        width: 160; height: 80
        system: particleSystem
        emitRate: 0
        lifeSpan: Emitter.InfiniteLife

        maximumEmitted: screen.maxNumOfParticles
    }

    Affector {
        system: particleSystem
        onAffectParticles: {
            var coordinates = box2DParticleSystem.particleCoordinates();
            var pixelsPerMeter = physicsWorld.pixelsPerMeter
            for( var i = 0; i < particles.length; i++) {
                var p = particles[i];
                p.x = coordinates[i*2] * pixelsPerMeter
                p.y = coordinates[i*2 + 1] * pixelsPerMeter * -1
                p.update = true
            }
        }
    }


    // DebugDraw {
    //     id: debugDraw
    //     world: physicsWorld
    //     opacity: 0.75
    //     visible: true
    // }


    Component.onCompleted: {
        createParticleRectangle (waveBox.x + 30, waveBox.y +30, 400, 100, 4);
    }

    function createParticleRectangle (x, y, width, height, particleDistance) {
        var pixelsPerMeter = physicsWorld.pixelsPerMeter
        for(var i = x; i < x + width; i += particleDistance)     {
            for(var j = y; j < y + height; j += particleDistance)     {
                box2DParticleSystem.addParticle(i / pixelsPerMeter, -j / pixelsPerMeter);
                emitter.burst(1);
            }
        }
    }
}

