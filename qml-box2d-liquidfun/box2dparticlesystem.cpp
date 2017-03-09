#include <QObject>

#include "box2dparticlesystem.h"
#include "box2dworld.h"


Box2dParticleSystem::Box2dParticleSystem(QObject *parent) :
    QObject(parent)
  , m_particleCreationDone(false)
  , m_damping(1.0)
  , m_world(0)
  , m_particleSystem(0)
  , m_particleHandle(0)
  , m_particleRadius(1.0)
{
}

void Box2dParticleSystem::addParticle(qreal x, qreal y, QQuickItem *target)
{
    if (m_world && m_particleSystem) {
        b2ParticleDef pd;
        pd.flags = b2_waterParticle; //b2_elasticParticle;
        pd.color.Set(0, 0, 255, 255);
        pd.position.Set(x, y);
        pd.userData = static_cast<void *>(target);
        // qDebug() << Q_FUNC_INFO << " - target: " << target << x << y;

        m_particleSystem->CreateParticle(pd);
    }
}

void Box2dParticleSystem::registerQmlObjectWithParticle(int index, QQuickItem *target)
{
    void **userDataBuffer = m_particleSystem->GetUserDataBuffer();
    *(userDataBuffer + index) = static_cast<void *>(target);
}


void Box2dParticleSystem::addParticleGroup(qreal x, qreal y, qreal width, qreal height, QVariantList particleArray)
{
    if (m_world && m_particleSystem) {

        b2PolygonShape shape;
        shape.SetAsBox((width/2), (height/2));
        // shape.SetAsBox(2, 1);
        b2ParticleGroupDef gd;
        gd.flags = b2_elasticParticle;
        gd.groupFlags = b2_solidParticleGroup;
        gd.position.Set((x+(width/2)), (y-(height/2)));
        gd.angle = -0.5f;
        gd.angularVelocity = 2.0f;
        gd.shape = &shape;
        gd.color.Set(0, 0, 255, 255);
        m_particleGroup = m_particleSystem->CreateParticleGroup(gd);
    }
}


void Box2dParticleSystem::particleCreationDone(bool done)
{
    m_particleCreationDone = done;
}


void Box2dParticleSystem::setParticleRadius(qreal arg)
{
    if (m_particleRadius == arg)
        return;

    m_particleRadius = arg;

    if (m_particleSystem) {
        m_particleSystem->SetRadius(m_particleRadius);
    }

    emit particleRadiusChanged(arg);
}

void Box2dParticleSystem::setDamping(qreal arg)
{
    if (m_damping == arg)
        return;

    m_damping = arg;

    if (m_particleSystem) {
        m_particleSystem->SetDamping(m_damping);
    }
    emit dampingChanged(arg);
}

QList<qreal> Box2dParticleSystem::particleCoordinates()
{
    if (!m_particleSystem) {
        return QList<qreal>();
    }

    QList<qreal> ret;
    int count = m_particleSystem->GetParticleCount();
    b2Vec2* positions = m_particleSystem->GetPositionBuffer();
    for(int i = 0; i < count; i++) {
        ret.append(positions[i].x);
        ret.append(positions[i].y);
    }

    return ret;
}

int Box2dParticleSystem::particleCount()
{
    return m_particleSystem->GetParticleCount();
}


qreal Box2dParticleSystem::particleRadius() const
{
    return m_particleRadius;
}

qreal Box2dParticleSystem::damping() const
{
    return m_damping;
}

Box2DWorld *Box2dParticleSystem::world() const
{
    return m_world;
}

void Box2dParticleSystem::createParticleSystem()
{
    const b2ParticleSystemDef particleSystemDef;
    m_particleSystem = m_world->world().CreateParticleSystem(&particleSystemDef);

    m_particleSystem->SetRadius(m_particleRadius);
    m_particleSystem->SetDamping(m_damping);
}

void Box2dParticleSystem::setWorld(Box2DWorld *world)
{
    if (m_world == world)
        return;

//    if (mWorld)
//        disconnect(mWorld, SIGNAL(pixelsPerMeterChanged()), this, SLOT(onWorldPixelsPerMeterChanged()));
//    if (world)
//        connect(world, SIGNAL(pixelsPerMeterChanged()), this, SLOT(onWorldPixelsPerMeterChanged()));

//    // Destroy body when leaving our previous world
//    if (mWorld && mBody) {
//        mWorld->world().DestroyBody(mBody);
//        mBody = 0;
//    }

    m_world = world;

    if (m_world)
        connect(m_world, SIGNAL(stepped()), SLOT(onWorldStepped()));
    
    createParticleSystem();
}

void Box2dParticleSystem::printParticleData()
{
    if (m_world && m_particleSystem) {
        int count = m_particleSystem->GetParticleCount();
        b2Vec2* positions = m_particleSystem->GetPositionBuffer();
        for(int i = 0; i < count; i++) {
            qDebug() << Q_FUNC_INFO << positions[i].x << positions[i].y;
        }
    }
}


void Box2dParticleSystem::syncParticles()
{
    if (m_particleCreationDone && m_world && m_particleSystem) {
        int overallParticleCount = m_particleSystem->GetParticleCount();
        b2Vec2* positions = m_particleSystem->GetPositionBuffer();
        // Particle coordinates are middle of particle, QML object top right corner.
        int pixelCorrection = m_world->toPixels(m_particleRadius);
        void **userDataBuffer = m_particleSystem->GetUserDataBuffer();

        if((userDataBuffer != NULL) && (*userDataBuffer != NULL)) {
            for(int i = 0; i < overallParticleCount; i++) {
                QQuickItem *target = static_cast<QQuickItem*>(*(userDataBuffer + i));
                // qDebug() << Q_FUNC_INFO << " - target: " << target << positions[i].x << positions[i].y;

                QPointF currentPosition = m_world->toPixels(*(positions + i));

                target->setX(currentPosition.x() - pixelCorrection);
                target->setY(currentPosition.y() - pixelCorrection);

            }
        }
    }
}

void Box2dParticleSystem::onWorldStepped()
{
    syncParticles();
}
