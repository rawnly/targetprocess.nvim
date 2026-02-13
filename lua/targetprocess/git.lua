local M = {}

--- Extract ticket ID from a branch name like `feature/12345_some_description`
---@param branch string
---@return string|nil
function M.get_ticket_id_from_branch(branch)
    -- Primary: prefix/ID_description
    local id = branch:match("%w+/(%d+)_.*")
    if id then
        return id
    end

    -- Fallback: any sequence of 4+ digits
    id = branch:match("(%d%d%d%d+)")
    return id
end

---@return string|nil
function M.current_branch()
    local result = vim.fn.systemlist("git branch --show-current")
    if vim.v.shell_error ~= 0 or #result == 0 then
        return nil
    end
    return vim.trim(result[1])
end

---@return string|nil
function M.extract_ticket_id()
    local branch = M.current_branch()
    if not branch then
        return nil
    end
    return M.get_ticket_id_from_branch(branch)
end

return M
