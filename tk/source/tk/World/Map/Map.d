module tk.World.Map.Map;

import std.path : exists;
import std.file : mkdir, write;
import std.string : endsWith;
import std.conv   : to;
import std.datetime;
import Common;
import tk.World.Chunk;

struct MapHeader
{
    char[5] magicNumber;
    float versionNumber;
}

struct TileData
{
    float x;
    float y;
    int type;
}

class Map
{
public:
    this()
    {
    }

    ///Saves the chunks inside of the map.
    ///Default to 0 for a new folder to be created, otherwise pass through the map name as unix time
    void saveMap(long folderName = 0)
    {
        if(folderName == 0 || !exists(folderName.to!string))
        {
            createFolder();
        }

        save();
    }

    ///Get all of the chunks to save in an array
    static void setChunks(Chunk[int][int] chunks)
    {
        this.chunks = chunks;
    }

private:
    static Chunk[int][int] chunks;
    string saveDir = "Assets\\Save\\";
    string currentDir = "";

    void createFolder()
    {
        ///Dear god of dots. ;_; I miss the real scope of for static from C++ ::
        string folderName = (saveDir ~ Clock.currTime.toUnixTime().to!string);

        ///Just some final error checking because I don't trust the code I write.
        if(!exists(folderName))
            mkdir(folderName);

        this.currentDir = folderName;
    }

    ///Save the data in totally soupy format
    ///
    ///Magic Number: TKMAP
    ///Version Number: 0.x
    ///
    ///Rest of file is Map data
    void save()
    {
        MapHeader[1] header;
        File f;

        header[0].magicNumber = "TKMAP";
        header[0].versionNumber = 0.01;

        ///By this point it is safe to assume that the file exsists
        f.open(this.currentDir ~ "\\Map.dat", "a+");

        f.rawWrite(header[0..1]);

        writeln(chunks);

        foreach(y; chunks.byKey)
        {
            foreach(x; chunks[y].byKey)
            {
                TileData[1] dat;

                auto chunk = chunks[y][x];

                for(int i = 0; i < chunk.getTiles().length; i++)
                {
                    for(int j = 0; j < chunk.getTiles()[i].length; j++)
                    {
                        dat[0].x = chunk.getTiles()[i][j].sprite.position.x;
                        dat[0].y = chunk.getTiles()[i][j].sprite.position.y;
                        dat[0].type = chunk.getTiles()[i][j].ID;

                        f.rawWrite(dat[0..1]);
                    }
                }
            }
        }

        f.close();
    }
}

