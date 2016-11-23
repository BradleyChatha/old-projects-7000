/// This module allows the engine developers to register slightly more complex unittests to run.
/// Please note that $(B only) tests that don't require human interaction should be placed here.
/// Tests needing human interaction should be created as a sub-package or something.
module jengine.testing;

@disable:
version(Engine_Tests)
{
    ///
    alias TestFunc = void function();
    unittest
    {
        import std.experimental.logger, std.file, std.path, sfml, std.parallelism, std.experimental.allocator, std.experimental.allocator.mallocator;
        import jengine.testing.t01, jengine.testing.t02, jengine.testing.t03;
        theAllocator = allocatorObject(Mallocator.instance);

        struct Test
        {
            string      name;
            TestFunc    func;
        }
        auto tests = 
        [
            Test("Dummy Test",                              &dummyTest),
            Test("Window and Input test",                   &t01),
            Test("Animation.create exceptions",             &t02),
            Test("Basic test of Engine",                    &t03)
        ];

        // Make sure we're in the "lib" folder.
        if(getcwd.dirName != "lib")
        {
            infof("[Not being ran in the lib folder. Attempting to switch directory to 'lib'.]");
            try
                chdir("lib");
            catch(Exception ex)
            {
                fatalf("[Could not switch to 'lib'. Aborting tests. Reason = %s]", ex.msg);
                return;
            }

            infof("[Running tests in folder %s]", getcwd);

            try
                loadSFML();
            catch(Exception ex)
            {
                fatalf("[Unable to load Derelict. Aborting tests. Reason = %s]", ex.msg);
                return;
            }
        }

        // Then run the tests.
        foreach(test; parallel(tests))
        {
            // I hope std.logger is thread-safe.
            infof("[Running Test '%s']", test.name);
            test.func();
        }

        infof("[All tests have ran successfully(probably)]");
    }

    private void dummyTest()
    {
        assert(2 == 2);
    }
}