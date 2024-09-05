local M = {
  icon = false
}

local function get_diagnostic_counts()
  local bufnr = vim.api.nvim_get_current_buf()
  local error_count = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warn_count = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  local hint_count = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })
  local info_count = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })

  local error = ""
  local warn = ""
  local hint = ""
  local info = ""

  if M.icon then
    if error_count > 0 then error = " " .. error_count .. " " end
    if warn_count > 0 then warn = " " .. warn_count .. " " end
    if hint_count > 0 then hint = " " .. hint_count .. " " end
    if info_count > 0 then info = " " .. info_count .. " " end
  else
    if error_count > 0 then error = "E:" .. error_count .. " " end
    if warn_count > 0 then warn = "W:" .. warn_count .. " " end
    if hint_count > 0 then hint = "H:" .. hint_count .. " " end
    if info_count > 0 then info = "I:" .. info_count .. " " end
  end

  return error .. warn .. hint .. info
end

local function get_git_branch()
  local handle = io.popen("git branch --show-current 2>/dev/null")
  if handle == nil then return "" end
  local branch = handle:read("*a")
  handle:close()

  branch = branch:gsub("%s+", "")

  if branch == "" then
    return ""
  else
    return " " .. branch .. " "
  end
end

M.setup = function(opts)
  M = vim.tbl_deep_extend("force", M, opts or {})

  vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter" }, {
    callback = function()
      local diag_info = get_diagnostic_counts()
      local git_branch = get_git_branch()
      vim.o.statusline = "%f %m " .. git_branch .. diag_info .. " %= %l:%c    %P"
    end,
  })
end

return M
