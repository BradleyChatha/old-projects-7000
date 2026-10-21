/+ dub.sdl:
   name "compile_tests"
   dependency "scriptlike" version="~>0.9.6"
+/
import scriptlike;

void main()
{
    scriptlikeEcho = true;
    auto cwd = getcwd();
    assert(cwd.baseName == "jengine", "The Current Working Directory must be at the root of the project.");

    foreach(Path entry; dirEntries(cwd ~ Path("tests"), SpanMode.shallow))
    {
        if(entry.isDir)
        {
            chdir(entry);
            run(text("dub build"));
        }
    }
}