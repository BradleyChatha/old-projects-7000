#include "Logger.h"

void Logger::Init(void)
{
	path Dir("Logs");

	if (!exists(Dir))
		create_directory(Dir);

	time_t t = time(NULL);
	struct tm* now = localtime(&t);
	string FileName = to_string((now->tm_year + 1900)) + "-" + to_string((now->tm_mon + 1)) + "-" + to_string(now->tm_mday) + " " + to_string(now->tm_hour) + " " + to_string(now->tm_min) + " " + to_string(now->tm_sec);

	LogFile.open("Logs\\" + FileName + ".txt");

	if (!LogFile)
		runtime_error("[Logger] Failed to create new Log File.");

	Logger::Write("[Logger] Created Log File.");
}

void Logger::Stop(void)
{
	Logger::Write("[Logger] Closing Log File.");
	LogFile.close();
}

void Logger::Write(string LogMessage, LogType Type)
{
	if (!LogFile)
		runtime_error("[Logger] Log File is not open.");

	time_t t = time(NULL);
	struct tm* now = localtime(&t);
	string TimeStamp = to_string(now->tm_hour) + ":" + to_string(now->tm_min) + ":" + to_string(now->tm_sec);
	string LogLevel = "";

	if (Type == LogType::Default)
		LogLevel = " [Default] ";
	else if (Type == LogType::Warning)
		LogLevel = " [Warning] ";
	else
		LogLevel = " [Fatal] ";

	LogFile << TimeStamp <<  LogLevel << LogMessage << endl;
	cout << TimeStamp << LogLevel << LogMessage << endl;
}
