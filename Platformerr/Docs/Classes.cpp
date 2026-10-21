Base class Actor (Everything which CAN move is to inherit from this class)

private:
    Sprite ActorSprite = The sprite/visual representation of the actor.
    Actor() = The Ctor is private the ensure no objects of it are made (Thanks STD library to teaching me this trick ;)).

protected: 
    bool IsAlive = Flag set to true if the object needs to be destroyed next frame.
    bool HasTime = Flags whether the timer is used or not for chosing how long the actor is alive for.
    Timer LifeTime = Dictates how long left the actor has to live.

public:
    virtual void Destroy() = 0 = Sets the IsAlive flag ready to destroy the object next frame.
    virutal void Move(vector2f) = 0 = moves the actor by n amount.
    virtual void teleport(vector2f) = 0 = teleports the actor to a new location.
    virutal void AssignTexture(Texture) = 0 = Gives the actors sprite a new texture.
    virtual void Update(float) = 0 = Updates the actor once a frame.

============================================================================================================
template<class T>
class ActorSpawner (Spawns actors of any type) = T is a class which inherits from Actor (e.g. Player)

private:
    unsigned int SpawnAmount = The amounts of actors to spawn.
    float SpawnInteval = The time between an actor being spawned.
    Timer SpawnTimer = The timer which dictates how often they can be spawned.
    bool CanSpawn = Sets whether the spawner is allowed to spawn any actors.

protected:

public:
    ActorSpawner(int = 0, float, bool = true) = A ctor which sets the SpawnAmount of actors and the spawn inteval.
                                   Sets CanSpawn to true by default.
    void Update(float) = Updates the spawner each frame.
    void StartSpawning(void) = Sets CanSpawn to true if false.
    void StopSpawning(void) = Sets CanSpawn to false if true.