/+dub.sdl:
    name "compile_shader"
    dependency "scriptlike" version="~>0.9.6"
+/

import scriptlike;
import std.getopt, std.json, std.algorithm, std.array;

void main(string[] args)
{
    struct Shader
    {
        string platform;
        string name;
        string vs_args;
        string fs_args;
    }
    auto shaders =
    [
        Shader("linux",   "glsl",   "-p 140",   "-p 140")
    ];

    version(Windows)
    {
        shaders ~= [Shader("windows", "dx9",  "-p vs_3_0 -O 3", "-p ps_3_0 -O 3"),
                    Shader("windows", "dx11", "-p vs_4_0 -O 3", "-p ps_4_0 -O 3")];
    }

    try
    {
        string    shadercPath;
        string    shaderFile;
        string    outputFolder;
        char      shaderType;
        Path      jenginePath;
        Path      varyingDefFile;
        string[]  includePaths;

        writeln("Helper tool for using shaderc with JEngine, by SealabJaster.");
        writeln("Use -h for more information.\n");
        auto status = args.getopt(                 "verbose|v",       "Print out additional information.",                                       &scriptlikeEcho,
                                  config.required, "inputfile|f",     "The input shader file.",                                                  &shaderFile,
                                  config.required, "outputFolder|o",  "The folder to output to.",                                                &outputFolder,
                                                   "shadercPath|scp", "The path to where the shaderc tool is. This is usually autodetected.",    &shadercPath);
        if(status.helpWanted)
        {
            defaultGetoptPrinter("Usage: compile_shader -f <input> -o <output> -p <platform>\nUse the -h argument for help.\n\nArguments:", status.options);
            return;
        }

        // Find the shader type
        yap("[Figuring out shader type]");
        if(shaderFile.extension      == ".vs") shaderType = 'v';
        else if(shaderFile.extension == ".fs") shaderType = 'f';
        else
            throw new Exception("The input file must have the extension of 'vs'(For Vertex Shader) or 'fs'(For Fragment Shader).");
        writeln("Shader Type: ", shaderType);

        // Find where JEngine is
        yap("[Finding path to JEngine]");
        auto output = runCollect("dub describe jengine");
        auto json   = parseJSON(output);
        json        = json.object["packages"];
        foreach(object; json.array)
        {
            if(object.object["name"].str == "jengine")
            {
                json = object;
                break;
            }
        }
        jenginePath = Path(json.object["path"].str);
        writeln("JEngine path: ", jenginePath);

        // Set where the varyingDefFile and default include path is.
        varyingDefFile = jenginePath ~ "deps/shader_include/varying.def.sc";
        includePaths  ~= (jenginePath ~ "deps/shader_include").toString;

        if(shadercPath is null)
        {
            version(Windows)
            {
                shadercPath = (jenginePath ~ "deps/win/tools/shaderc").toString;
            }
        }

        // Then call shaderc
        auto scp = Path(shadercPath);
        auto sfp = Path(shaderFile);
        auto ofp = Path(outputFolder);

        foreach(shader; shaders)
        {
            yap(format("[Calling shaderc for shader type %s]", shader.name));
            run(format("%s -f %s -o %s --type %s --platform %s --varyingdef %s %s %s",
                      scp.toRawString,
                      sfp,
                      ofp ~ format("%s.%s", shaderFile.baseName, shader.name),
                      shaderType,
                      shader.platform,
                      varyingDefFile,
                      includePaths.map!(s => "-i " ~ Path(s).toRawString).join(" "),
                      (shaderType == 'v') ? shader.vs_args : shader.fs_args));
        }
        writeln("Done!");
    }
    catch(Exception ex)
    {
        writefln("\nAn exception was thrown when compiling shader: %s", ex.msg);
        debug throw ex;
    }
}