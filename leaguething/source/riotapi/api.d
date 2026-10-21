module riotapi.api;

private
{
    import std.net.curl, std.json, std.exception, std.range, std.array, std.algorithm.iteration;
    import std.conv : to;
    import std.format : format;
    import std.file : write, readText, exists;
    import std.datetime : Clock, StopWatch, AutoStart;
    import std.stdio : writefln;

    import core.thread;
    import core.time : Duration, dur;

    import d2sqlite3;

    alias Table = JSONValue[string];
    alias List  = JSONValue[];
}

/// The status codes the api may return.
enum StatusCode : ushort
{
    /// This response indicates a syntax error in the request. 
    Bad_Request         = 400,
    
    /// Something's wrong with the API key(such as one not being supplied). 
    Unauthorised        = 401,
    
    /// An id/name was not found for the request, or the request was invalid. 
    Not_Found           = 404,
    
    /// The request rates have been used up. No further requests should be made, otherwise the risk of being blacklisted is made. 
    Rate_Limit_Exceeded = 429
}

/// A response from the API
private struct ApiResponse
{
    /// The status code returned.
    ushort      code;

    /// How many seconds to wait if we hit a rate limit.
    int         timeout;

    /// Which type of limit we hit.
    string      limitType;

    /// The JSON data returned.
    Table       data;
}

/// Provides access to the Riot games API.
/// Note: Forcefully makes the program sleep if StatusCode.Rate_Limit_Exceeded is returned.
class RiotGamesApi
{
    private
    {
        immutable static    _retryHeaderName    = "Retry-After";
        immutable static    _timeKey            = "__Time";
        immutable static    _cacheFile          = "Cache.json";

        // Some statements
        Database    _sql;
        Statement   _addIntoCache;
        Statement   _getFromCache;
        Statement   _removeFromCache;

        /// The API key
        immutable(string)   _key;

        /// Sends a GET to the url, and parses some of the data.
        /// Ensures that this function takes at least 1 second to perform. To help keep under the rate limit
        /// TODO: Remove the above functionality if you ever get a production key.
        /// 
        /// Parameters:
        ///     timeToCache = How long to keep the response in the cache(if it's not already cached).
        Table get(in string url, Duration timeToCache)
        {
            // Time the function, so we can sleep if we need to.
            auto watch = StopWatch(AutoStart.yes);

            // The table to return
            Table response;

            // See if it's already cached
            auto cacheKey   = url[0..$-this._key.length];

            this._getFromCache.bindAll(cacheKey);
            auto results = RowCache(this._getFromCache.execute());
            this._getFromCache.reset();

            if(results.length == 0)
            {
                ApiResponse toReturn;

                // Send the GET and parse it's response
                ubyte[] buffer;

                HTTP request = HTTP(url);
                request.method = HTTP.Method.get;
                request.onReceiveHeader = 
                    (in char[] key, in char[] value) 
                    {   if(key == this._retryHeaderName)    toReturn.timeout = to!int(value);
                        else if(key == "X-Rate-Limit-Type") toReturn.limitType = to!string(value);
                    };
                request.onReceive =
                    (ubyte[] data) {buffer ~= data.dup; return data.length;};
                request.onReceiveStatusLine =
                    (HTTP.StatusLine status) {toReturn.code = status.code;};
                request.perform();

                toReturn.data = parseJSON(cast(char[])buffer).object;

                // If we've hit the rate limit, sleep and then try again.
                if(toReturn.code == StatusCode.Rate_Limit_Exceeded)
                {
                    auto time = (toReturn.timeout + 2);
                    writefln("Rate limit hit for '%s'. Thread sleeping for %s seconds. Please wait...", toReturn.limitType, time);

                    Thread.sleep(seconds(time));
                    return this.get(url, timeToCache);
                }
                enforce(toReturn.code == 200, new RiotGamesException(toReturn.code));

                // Cache it
                toReturn.data[this._timeKey] = (Clock.currStdTime + timeToCache.total!"hnsecs");
                JSONValue root = toReturn.data;
                this._addIntoCache.bindAll(cacheKey, toJSON(&root));
                this._addIntoCache.execute();
                this._addIntoCache.reset();

                response = toReturn.data;
            }
            else
            {
                // If it's time in the cache is up, remove it and get a new response.
                auto object = parseJSON(results.rows[0]["json"].as!string).object;
                if(object[this._timeKey].integer <= Clock.currStdTime)
                {
                    this._removeFromCache.bindAll(cacheKey);
                    this._removeFromCache.execute();
                    this._removeFromCache.reset();
                    response = this.get(url, timeToCache);
                }
                else
                {
                    // If we've used the cache, we don't need to bother going through the time restraint.
                    return object;
                }
            }

            // If the function hasn't taken 1 second yet, sleep for 1.1 seconds(just to be safe <3).
            auto duration = watch.peek();
            if(duration.seconds < 1)
            {
                Thread.sleep(dur!"msecs"(1100 - duration.msecs));
            }

            return response;
        }

        /// Builds a url to GET.
        /// 
        /// Parameters:
        ///     staticData = Set to true if you're requesting static data.
        ///     region  = The region to get the data from.
        ///     api     = The api-specific part of the url.
        immutable(string) buildUrl(bool staticData = false)(in string region, in string api)
        {
            assert(api[0] != '/' && api[$-1] != '/', "'api' must not end or start with a '/'");
            return format("https://%s.api.pvp.net/api/lol/%s/%s/?api_key=%s", (staticData) ? "global" : region, region, api, this._key).assumeUnique;
        }

        void setupStatements()
        {
            // Make sure the table is created
            this._sql.execute(
                `CREATE TABLE IF NOT EXISTS cache 
                (
                    id INTEGER PRIMARY KEY,
                    url TEXT NOT NULL,
                    json TEXT NOT NULL
                )`);

            this._addIntoCache = this._sql.prepare(
                `INSERT INTO cache (url, json) VALUES (:url, :json)`
                );

            this._getFromCache = this._sql.prepare(
                `SELECT * FROM cache WHERE url == :url`
                );

            this._removeFromCache = this._sql.prepare(
                `DELETE FROM cache WHERE url == :url`
                );
        }
    }

    public
    {
        /// Constructs a new interface that uses the given API key.
        /// Will use the given database to store the cache.
        this(immutable(string) key, Database sql)
        {
            this._key = key;
            this._sql = sql;

            this.setupStatements();
        }

        /// Returns basic information about some summoners.
        /// 
        /// Parameters:
        ///     region      = The region to look for the summoner in.
        ///     usernames    = The summoners' standardised usernames.
        ///     
        /// Example:
        /// ---
        ///     auto api = new RiotGamesApi("super-secret-key");
        ///     Table data = api.summonerByName("euw", "sealabjaster");
        ///     auto level = data["sealabjaster"]["summonerLevel"].integer;
        /// ---
        ///    
        /// Returns:
        ///     A JSON table containing -
        ///         "$(B username)" = Another table, containing data about the player.
        ///             "id"            = The player's ID
        ///             "name"          = The player's in-game name
        ///             "profileIconID" = The ID of the player's icon
        ///             "revisionDate"  = No need to worry about this
        ///             "summonerLevel" = What level they are.
        Table summonerByName(string region, string[] usernames)
        {
            return this.get(
                this.buildUrl(region, "v1.4/summoner/by-name/"~usernames.join(",")), 
                dur!"hours"(6)
                );
        }

        /// Ditto
        Table summonerById(string region, ulong[] ids)
        {
            auto summoners = ids.map!(to!(string)).join(",");
            return this.get(this.buildUrl(region, "v1.4/summoner/"~summoners), dur!"hours"(6));
        }

        /// Returns the in-game names of the summoners.
        /// 
        /// Parameters:
        ///     region = The region the summoners are in.
        ///     ids = The summoner ids to use.
        ///     
        /// Returns:
        ///     An object of - "id" = "name"
        Table summonerNamesById(string region, ulong[] ids)
        {
            auto summoners = ids.map!(to!(string)).join(",");
            return this.get(this.buildUrl(region, format("v1.4/summoner/%s/name", summoners)), dur!"days"(30));
        }

        /// Returns the details of the summoner's mastery pages.
        /// 
        /// Parameters:
        ///     region = The region of the players.
        ///     ids = The summoners to get the mastery pages of.
        ///     
        /// Returns:
        ///     The data is a bit bigger than the other function's data. So refer to the online documentation.
        Table summonerMasteries(string region, ulong[] ids)
        {
            auto summoners = ids.map!(to!(string)).join(",");
            return this.get(this.buildUrl(region, format("v1.4/summoner/%s/masteries", summoners)), dur!"hours"(2));
        }

        /// Returns the details of the summoners' rune pages.
        /// 
        /// Parameters:
        ///     region = The region of the summoners.
        ///     ids = The summoners to get the rune pages of.
        ///     
        /// Returns:
        ///     Refer to the online documentation.
        Table summonerRunes(string region, ulong[] ids)
        {
            auto summoners = ids.map!(to!(string)).join(",");
            return this.get(this.buildUrl(region, format("v1.4/summoner/%s/runes", summoners)), dur!"hours"(2));
        }

        // TODO: Create a function to create a standardised username
        // TODO: Use an SQL database to store things like the cache(we can then just use the same database to store the program's data).
    }
}

/// Thrown when something goes wrong when using the API.
class RiotGamesException : Exception
{
    private
    {
        ushort _code;
    }

    public
    {
        /**
     * Creates a new instance of Exception. The next parameter is used
     * internally and should always be $(D null) when passed by user code.
     * This constructor does not automatically throw the newly-created
     * Exception; the $(D throw) statement should be used for that purpose.
     */
        this(ushort code, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
        {
            this._code = code;
            super(format("Bad status code returned: %s", code), file, line, next);
        }

        /// Get the status code that caused this exception.
        @property
        ushort statusCode()
        {
            return this._code;
        }
    }
}