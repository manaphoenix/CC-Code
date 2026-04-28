---@diagnostic disable: undefined-doc-name
local bsky = {}

---@class request
---@field url string
---@field body? string
---@field headers? table<string, string>
---@field binary? boolean
---@field method? string
---@field redirect? boolean
---@field timeout? number

---@class loginInfo
---@field id string
---@field password string

---@class Post
---@field type string should be $type but EmmyLua doesn't support that
---@field text string the message of the post
---@field createdAt string
---@field langs? string[] see https://www.techonthenet.com/js/language_tags.php

---@class LoginData
---@field authToken string
---@field refreshToken string
---@field did string

local Post = {}
Post.__index = Post

--- Create a new post object
---@param text string the text of the post
---@param lang? string the language of the post (defaults to English)
---@return Post
function Post.new(text, lang)
    local self = setmetatable({}, Post)
    self["$type"] = "app.bsky.feed.post"  -- Keep the required name for the API
    self.text = text
    self.createdAt = os.date("%Y-%m-%dT%H:%M:%SZ") -- stupid EmmyLua :(
    self.langs = lang and {lang} or {"en-US"} -- default to English
    return self
end

--- Make a POST request
---@param request request
---@return ccTweaked.http.BinaryResponse|ccTweaked.http.Response|nil response, string error, ccTweaked.http.BinaryResponse|ccTweaked.http.Response|nil code
local function makePostRequest(request)
    local response, err, code = http.post(request)
    return response, err, code
end

--- Login to BSKY
---@param handle string the handle to login with
---@param password string the password to login with
---@return LoginData|nil, string? error, ccTweaked.http.BinaryResponse|ccTweaked.http.Response|nil? code
local function loginToBSKY(handle, password)
    local request = {
        url = "https://bsky.social/xrpc/com.atproto.server.createSession",
        body = textutils.serialiseJSON({
            identifier = handle,
            password = password
        }),
        headers = {
            ["Content-Type"] = "application/json"
        }
    }
    local loginAttempt, err, code = makePostRequest(request)
    if not loginAttempt then
        return nil, err, code
    end
    local response = textutils.unserialiseJSON(loginAttempt.readAll())
    local auth, refreshAuth = response["accessJwt"], response["refreshJwt"]
    local repo = response["did"]
    loginAttempt.close()
    return {
        authToken = auth,
        refreshToken = refreshAuth,
        did = repo
    }
end

--- Post to BSKY
---@param loginData LoginData
---@param postData Post
---@return ccTweaked.http.BinaryResponse|ccTweaked.http.Response|nil response, string? error, ccTweaked.http.BinaryResponse|ccTweaked.http.Response|nil? code
local function postToBSKY(loginData, postData)
    local request = {
        url = "https://bsky.social/xrpc/com.atproto.repo.createRecord",
        headers = {
            ["Authorization"] = "Bearer " .. loginData.authToken,
            ["Content-Type"] = "application/json"
        },
        body = textutils.serialiseJSON({
            repo = loginData.did,
            collection = "app.bsky.feed.post",
            record = postData
        })
    }
    return makePostRequest(request)
end

--- Refresh the access token
---@param loginData LoginData
---@return table<number,string>|nil response, string? error, ccTweaked.http.BinaryResponse|ccTweaked.http.Response|nil? code
local function refreshToken(loginData)
    local request = {
        url = "https://bsky.social/xrpc/com.atproto.server.refreshSession",
        headers = {
            ["Authorization"] = "Bearer " .. loginData.refreshToken,
        }
    }
    local refreshAttempt, err, code = makePostRequest(request)
    if not refreshAttempt then
        return nil, err, code
    end
    local respCode = {refreshAttempt.getResponseCode()}
    refreshAttempt.close()
    return respCode
end

bsky.Post = Post
bsky.loginToBSKY = loginToBSKY
bsky.postToBSKY = postToBSKY
bsky.refreshToken = refreshToken

return bsky
