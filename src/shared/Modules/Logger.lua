local Logger = {}
Logger.__index = Logger

function Logger.new(LogName, Debug, LanguageParser)
    local self = setmetatable({}, Logger)

    self.LogName = LogName
    self.IsDebug = Debug or false
    self._languageParser = LanguageParser or function(m)
        return m
    end

    return self
end

function Logger:Fatal(message,...)
    error(`[FATAL] [{self.LogName}] [{getfenv(2).script.Name}] : {self._languageParser(message,...)}`)
end

function Logger:Error(message,...)
    warn(`[ERROR] [{self.LogName}] [{getfenv(2).script.Name}] : {self._languageParser(message,...)}`)
end

function Logger:Warn(message,...)
    warn(`[WARN] [{self.LogName}] [{getfenv(2).script.Name}] : {self._languageParser(message,...)}`)
end

function Logger:Debug(message,...)
    if self.IsDebug == false then return end
    warn(`[DEBUG] [{self.LogName}] [{getfenv(2).script.Name}] : {self._languageParser(message,...)}`)
end

function Logger:Assert(condition, message,...)
    if not condition then
        error(`[ASSERT] [{self.LogName}] [{getfenv(2).script.Name}] : {self._languageParser(message,...)}`)
    end
end

function Logger.__call(self, message,...)
    print(`[LOG] [{self.LogName}] [{getfenv(2).script.Name}] : {self._languageParser(message,...)}`)
end

return Logger