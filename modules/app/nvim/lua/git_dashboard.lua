local M = {}
local uv = vim.loop

-- Simple in‑memory cache
local cache = {
  repos = { ts = 0, items = {} },
}

local function is_git_dir(p)
  local st = uv.fs_stat(p .. "/.git")
  return st and st.type == "directory"
end

local function head_mtime(p)
  local st = uv.fs_stat(p .. "/.git/HEAD")
  return (st and st.mtime and st.mtime.sec) or 0
end

-- Scan base directories (depth 1) and include base if it’s a repo
function M.get_local_repos(base_dirs, max_repos)
  local now = vim.loop.now() / 1000
  if now - cache.repos.ts < 15 and #cache.repos.items > 0 then
    return cache.repos.items
  end

  local repos = {}
  for _, base in ipairs(base_dirs) do
    local expanded = vim.fn.expand(base)

    if is_git_dir(expanded) then
      table.insert(repos, {
        path = expanded,
        name = vim.fn.fnamemodify(expanded, ":t"),
        mtime = head_mtime(expanded),
      })
    end

    local handle = uv.fs_scandir(expanded)
    if handle then
      while true do
        local name = uv.fs_scandir_next(handle)
        if not name then break end
        local full = expanded .. "/" .. name
        local st = uv.fs_stat(full)
        if st and st.type == "directory" and is_git_dir(full) then
          table.insert(repos, {
            path = full,
            name = name,
            mtime = head_mtime(full),
          })
        end
      end
    end
  end

  table.sort(repos, function(a, b) return a.mtime > b.mtime end)
  local items = {}
  local limit = math.min(#repos, max_repos or #repos)
  for i = 1, limit do
    local r = repos[i]
    table.insert(items, {
      icon = "",
      desc = r.name,
      key = tostring(i),
      action = function()
        vim.cmd("cd " .. r.path)
        vim.cmd("edit .")
      end,
    })
  end

  cache.repos.items = items
  cache.repos.ts = now
  return items
end

local function in_git_repo()
  return vim.fn.isdirectory(".git") == 1
end

function M.get_recent_commits(n)
  if not in_git_repo() then return {} end
  local result = vim.system({ "git", "log", "--oneline", "-" .. tostring(n) }, { text = true }):wait()
  if result.code ~= 0 then return {} end
  local items = {}
  for line in result.stdout:gmatch("[^\n]+") do
    local sha, msg = line:match("^(%x+)%s+(.*)")
    if sha then
      table.insert(items, {
        icon = "",
        desc = msg,
        action = function()
          vim.cmd("tabnew")
          vim.api.nvim_buf_set_option(0, "buftype", "nofile")
          vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
          vim.api.nvim_buf_set_option(0, "swapfile", false)
          local out = vim.system({ "git", "show", "--color=always", sha }, { text = true }):wait()
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out.stdout or "", "\n"))
          vim.bo.filetype = "gitcommit"
          vim.bo.modifiable = false
          vim.cmd("normal! gg")
        end,
      })
    end
  end
  return items
end

function M.get_changed_files()
  if not in_git_repo() then return {} end
  local result = vim.system({ "git", "status", "--porcelain" }, { text = true }):wait()
  if result.code ~= 0 then return {} end
  local items = {}
  for line in result.stdout:gmatch("[^\n]+") do
    local status, file = line:match("^(..)%s+(.*)")
    if file then
      table.insert(items, {
        icon = "",
        desc = status .. " " .. file,
        action = function() vim.cmd("edit " .. file) end,
      })
    end
  end
  return items
end

return M
