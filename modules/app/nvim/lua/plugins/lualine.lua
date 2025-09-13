return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
      local colors = {
        blue   = '#80a0ff',
        orange = '#ff7733',
        cyan   = '#79dac8',
        black  = '#080808',
        white  = '#c6c6c6',
        red    = '#ff5189',
        violet = '#d183e8',
        grey   = '#303030',
        BG = '#16181b',
        FG = '#c5c4c4',
        YELLOW = '#e8b75f',
        CYAN = '#00bcd4',
        DARKBLUE = '#2b3e50',
        GREEN = '#00e676',
        ORANGE = '#ff7733',
        VIOLET = '#7a3ba8',
        MAGENTA = '#d360aa',
        BLUE = '#4f9cff',
        RED = '#ff3344',
      }

      local bubbles_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.violet },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.white, bg = colors.BG },
        },
        insert = { a = { fg = colors.black, bg = colors.blue } },
        visual = { a = { fg = colors.black, bg = colors.cyan } },
        replace = { a = { fg = colors.black, bg = colors.red } },
        command = { a = { fg = colors.black, bg = colors.orange} },
        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white, bg = colors.BG },
        },
      }

      -- Solo lettera della modalità
      local function mode_letter()
        local map = {
          n = 'N', i = 'I', v = 'V', [''] = 'V', V = 'V', c = 'C', no = 'N', s = 'S', S = 'S',
          ic = 'I', R = 'R', Rv = 'R', cv = 'C', ce = 'C', r = 'R', rm = 'M', ['r?'] = '?', ['!'] = '!', t = 'T'
        }
        return map[vim.fn.mode()] or '?'
      end

      -- Nome branch compatto
      local function branch_fmt(branch)
        if not branch or branch == '' then return 'No Repo' end
        local function trunc(seg, len) return #seg > len and seg:sub(1,len) or seg end
        local segs = {}; for s in branch:gmatch('[^/]+') do table.insert(segs,s) end
        for i=1,#segs-1 do segs[i]=trunc(segs[i],1) end
        if #segs==1 then return segs[1] end
        segs[1] = segs[1]:upper(); for i=2,#segs-1 do segs[i]=segs[i]:lower() end
        local out = table.concat(segs,'',1,#segs-1)..'›'..segs[#segs]
        if #out>15 then out=out:sub(1,15)..'…' end
        return out
      end

      -- Tabs/Spaces
      local function tab_spaces()
        if vim.bo.expandtab then
          return 'Spaces:' .. vim.bo.shiftwidth()
        else
          return 'Tab:' .. vim.bo.tabstop
        end
      end

      -- Orario
      local function time_now()
        return os.date("%H:%M")
      end

      -- Directory corrente
      local function cwd()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
      end

      -- Macro recording
      local function macro_recording()
        local reg = vim.fn.reg_recording()
        return reg ~= '' and 'REC [' .. reg .. ']' or ''
      end

      -- Barra grafica di progress
      local function progress_bar()
        local current_line = vim.fn.line('.')
        local total_lines = vim.fn.line('$')
        local chars = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
        local idx = math.floor((current_line / total_lines) * (#chars - 1)) + 1
        return chars[idx]
      end

      -- Visual mode indicator
      local function visual_mode()
        local m = vim.fn.mode()
        if m == 'v' then return 'V' end
        if m == 'V' then return 'VL' end
        if m == '' then return 'VB' end
        return ''
      end

      require('lualine').setup {
        options = {
          theme = bubbles_theme,
          component_separators = '',
          section_separators = { left = '', right = '' },
          disabled_filetypes = { 'neo-tree', 'undotree', 'sagaoutline', 'diff' },
        },
        sections = {
          lualine_a = {
            {
              mode_letter,
              separator = { left = '', right = '' },
              right_padding = 2
            },
          },
          lualine_b = {
            { function() return cwd() end, icon = '', color = { fg = colors.YELLOW } },
            { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
            { 'filename', file_status = true, path = 1 },
            { 
              'branch', 
              icon = '', 
              fmt = branch_fmt,
            },
            {
              'diff',
              colored = true,
              symbols = { added = ' ', modified = ' ', removed = ' ' },
              diff_color = {
                added    = { fg = colors.GREEN },
                modified = { fg = colors.YELLOW },
                removed  = { fg = colors.RED },
              },
            },
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              sections = { 'error', 'warn', 'info', 'hint' },
              symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
              always_visible = false,
            },
          },
          lualine_c = {},
          lualine_x = {
            { tab_spaces, icon = '⇥' },
            { time_now, icon = '' },
            { macro_recording, color = { fg = colors.RED, gui = 'bold' }, cond = function() return vim.fn.reg_recording() ~= '' end },
            { visual_mode, color = { fg = colors.violet, gui = 'bold' }, cond = function()
                local m = vim.fn.mode()
                return m == 'v' or m == 'V' or m == ''
              end
            },
            { progress_bar,  padding = { left = 0, right = 1 } }
          },
          lualine_y = { 'progress' },
          lualine_z = {
            { 'location', separator = { right = '' }, left_padding = 2 },
          },
        },
        inactive_sections = {
          lualine_a = { 'filename' },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { 'location' },
        },
        tabline = {},
        extensions = {},
      }
    end,
  }
}
