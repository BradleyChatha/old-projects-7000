#pragma once
#define BOOST_FILESYSTEM_NO_DEPRECATED

#include <fstream>
#include <string>
#include <iostream>
#include <boost\filesystem.hpp>

using namespace std;
using namespace boost::filesystem;

namespace {
	static ofstream LogFile;
}

enum class LogType
{
	Default = 0, ///Used for standard logs (e.g. "Loaded texture DankMeme.png").
	Warning, ///For things that are worrying but doesn't stop the program from running.
	Fatal ///EVERYTHING HAS GONE WRONG. RED ALERT, RED ALERT. THIS IS NOT A DRILL. EVERY MAN FOR HIMSELF.
};

static class Logger
{
public:
	static void Init(void);
	static void Stop(void);
	static void Write(string LogMessage, LogType Type = LogType::Default);
};

