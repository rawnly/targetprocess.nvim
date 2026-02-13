local M = {}

---@class targetprocess.Config
---@field base_url string
---@field token string

---@type targetprocess.Config
local config = {
    base_url = "",
    token = "",
}

---@param opts targetprocess.Config
function M.setup(opts)
    config = vim.tbl_extend("force", config, opts)
end

---@class targetprocess.Assignable
---@field Id number
---@field Name string
---@field Description string|nil

---@param id string
---@param callback fun(err: string|nil, assignable: targetprocess.Assignable|nil)
function M.get_assignable(id, callback)
    if config.base_url == "" or config.token == "" then
        callback("targetprocess: base_url and token must be configured", nil)
        return
    end

    local url = string.format(
        "%s/api/v1/Assignables/%s?access_token=%s&format=json",
        config.base_url,
        id,
        config.token
    )

    vim.system(
        { "curl", "-sf", "-H", "Accept: application/json", url },
        { text = true },
        function(result)
            vim.schedule(function()
                if result.code ~= 0 then
                    callback(string.format("targetprocess: failed to fetch assignable #%s", id), nil)
                    return
                end

                local ok, data = pcall(vim.json.decode, result.stdout)
                if not ok then
                    callback("targetprocess: failed to parse API response", nil)
                    return
                end

                callback(nil, data)
            end)
        end
    )
end

function M._base_url()
    return config.base_url
end

return M
