local git = require("targetprocess.git")
local api = require("targetprocess.api")
local ui = require("targetprocess.ui")

local M = {}

---@class targetprocess.SetupOpts
---@field base_url string TargetProcess instance URL (e.g. "https://company.tpondemand.com")
---@field token string API access token

---@param opts targetprocess.SetupOpts
function M.setup(opts)
    opts = opts or {}

    if not opts.base_url or not opts.token then
        vim.notify("targetprocess: base_url and token are required", vim.log.levels.ERROR)
        return
    end

    -- Strip trailing slash
    opts.base_url = opts.base_url:gsub("/$", "")

    api.setup(opts)

    vim.api.nvim_create_user_command("TargetProcessView", function(cmd)
        M.view(cmd.args ~= "" and cmd.args or nil)
    end, { nargs = "?", desc = "View current TargetProcess user story" })

    vim.api.nvim_create_user_command("TargetProcessOpen", function(cmd)
        M.open(cmd.args ~= "" and cmd.args or nil)
    end, { nargs = "?", desc = "Open current TargetProcess user story in browser" })
end

--- Resolve a ticket ID from the argument or current branch
---@param id_or_url? string
---@return string|nil
local function resolve_id(id_or_url)
    if id_or_url then
        -- Try extracting from URL
        local id = id_or_url:match("entity/(%d+)")
        return id or id_or_url
    end
    return git.extract_ticket_id()
end

--- Convert HTML description to plain-ish text
---@param html string
---@return string[]
local function html_to_lines(html)
    local text = html
    -- Convert common HTML to markdown-ish
    text = text:gsub("<!--markdown-->", "")
    text = text:gsub("<br%s*/?>", "\n")
    text = text:gsub("<p>", ""):gsub("</p>", "\n")
    text = text:gsub("<strong>(.-)</strong>", "**%1**")
    text = text:gsub("<b>(.-)</b>", "**%1**")
    text = text:gsub("<em>(.-)</em>", "*%1*")
    text = text:gsub("<i>(.-)</i>", "*%1*")
    text = text:gsub("<code>(.-)</code>", "`%1`")
    text = text:gsub("<li>", "- "):gsub("</li>", "\n")
    text = text:gsub("<[^>]+>", "") -- strip remaining tags
    text = text:gsub("&amp;", "&")
    text = text:gsub("&lt;", "<")
    text = text:gsub("&gt;", ">")
    text = text:gsub("&nbsp;", " ")
    text = text:gsub("&quot;", '"')
    -- Collapse multiple blank lines
    text = text:gsub("\n\n\n+", "\n\n")
    return vim.split(vim.trim(text), "\n")
end

---@param id_or_url? string
function M.view(id_or_url)
    local id = resolve_id(id_or_url)
    if not id then
        vim.notify("targetprocess: could not determine ticket ID from branch", vim.log.levels.WARN)
        return
    end

    vim.notify(string.format("targetprocess: fetching #%s...", id), vim.log.levels.INFO)

    api.get_assignable(id, function(err, assignable)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
            return
        end

        local lines = {
            string.format("# [#%d] %s", assignable.Id, assignable.Name),
            "",
        }

        if assignable.Description and assignable.Description ~= "" then
            local desc_lines = html_to_lines(assignable.Description)
            vim.list_extend(lines, desc_lines)
        else
            table.insert(lines, "*No description*")
        end

        ui.open_float(lines, { title = string.format("TargetProcess #%d", assignable.Id) })
    end)
end

---@param id_or_url? string
function M.open(id_or_url)
    local id = resolve_id(id_or_url)
    if not id then
        vim.notify("targetprocess: could not determine ticket ID from branch", vim.log.levels.WARN)
        return
    end

    local url = string.format("%s/entity/%s", api._base_url(), id)
    vim.ui.open(url)
end

return M
