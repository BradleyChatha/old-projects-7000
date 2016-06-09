typedef struct PointLabel
{
    int x;
    int y;
} Point;

Point* point_Set(int newX, int newY)
{
    Point* newPoint;
    newPoint->x = newX;
    newPoint->y = newY;
    return newPoint;
}