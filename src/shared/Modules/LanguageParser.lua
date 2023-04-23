local LanguageParser = {}
LanguageParser.__index = LanguageParser

function LanguageParser.new(Language)
    assert(Language, "Language not provided")
    local self = setmetatable({}, LanguageParser)

    self.Language = Language
    self.LanguageCache = {}

    return self
end

function LanguageParser.__call(self, m, ...)
    if self.LanguageCache[m] then
        return self.LanguageCache
    end

    for pattern, Replacement in pairs(self.Language) do
        m = string.gsub(m, pattern, Replacement)
    end

    m = string.format(m, ...)

    return m
end

return LanguageParser