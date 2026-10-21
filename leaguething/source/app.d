import std.stdio;

import d2sqlite3;

import riotapi.api;

void main()
{
    auto sql = Database("Data.db");
    auto api = new RiotGamesApi("e01f3c46-1928-4ea3-b5ac-064ef41a0d79", sql);

    writeln(api.summonerByName("euw", ["sealabjaster","lewthapro"]));
    writeln(api.summonerById("euw", [47480873, 32128823]));
    writeln(api.summonerMasteries("euw", [47480873]));
    writeln(api.summonerRunes("euw", [47480873]));
}
