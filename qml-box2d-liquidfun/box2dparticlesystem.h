#ifndef BOX2DPARTICLESYSTEM_H
#define BOX2DPARTICLESYSTEM_H

#include <QObject>
#include <QQuickItem>

#include <Box2D.h>

class Box2DWorld;

class Box2dParticleSystem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Box2DWorld *world READ world WRITE setWorld NOTIFY worldChanged)
    Q_PROPERTY(qreal particleRadius READ particleRadius WRITE setParticleRadius NOTIFY particleRadiusChanged)
    Q_PROPERTY(qreal damping READ damping WRITE setDamping NOTIFY dampingChanged)

public:
    explicit Box2dParticleSystem(QObject *parent = 0);

    Box2DWorld * world() const;
    Q_INVOKABLE QList<qreal> particleCoordinates();
    Q_INVOKABLE int particleCount();

    qreal particleRadius() const;
    qreal damping() const;

    void syncParticles();

    bool m_particleCreationDone;

signals:
    void worldChanged(Box2DWorld * arg);
    void particleRadiusChanged(qreal arg);
    void dampingChanged(qreal arg);

public slots:
    void setWorld(Box2DWorld *world);
    void printParticleData();
    void addParticle(qreal x, qreal y, QQuickItem *target);
    void registerQmlObjectWithParticle(int index, QQuickItem *target);
    void addParticleGroup(qreal x, qreal y, qreal width, qreal height, QVariantList particleArray);
    void setParticleRadius(qreal arg);
    void setDamping(qreal arg);
    void particleCreationDone(bool done);

private:
    void createParticleSystem();

    qreal m_damping;

private slots:
    void onWorldStepped();

protected:
    Box2DWorld* m_world;

    b2ParticleSystem* m_particleSystem;
    b2ParticleGroup* m_particleGroup;
    b2ParticleHandle* m_particleHandle;
    qreal m_particleRadius;

};

#endif // BOX2DPARTICLESYSTEM_H
