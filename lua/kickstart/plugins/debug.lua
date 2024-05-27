return {

  'mfussenegger/nvim-dap',

  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    'theHamsta/nvim-dap-virtual-text',
    'nvim-telescope/telescope-dap.nvim',

    -- Add your own debuggers here
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    vim.g.dotnet_build_project = function()
      local default_path = vim.fn.getcwd() .. '/'
      if vim.g['dotnet_last_proj_path'] ~= nil then
        default_path = vim.g['dotnet_last_proj_path']
      end
      local path = vim.fn.input('Path to your *proj file', default_path, 'file')
      vim.g['dotnet_last_proj_path'] = path
      local cmd = 'dotnet build -c Debug ' .. path .. ' > /dev/null'
      print ''
      print('Cmd to execute: ' .. cmd)
      local f = os.execute(cmd)
      if f == 0 then
        print '\nBuild: ✔️ '
      else
        print('\nBuild: ❌ (code: ' .. f .. ')')
      end
    end

    vim.g.dotnet_get_dll_path = function()
      local request = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
      end

      if vim.g['dotnet_last_dll_path'] == nil then
        vim.g['dotnet_last_dll_path'] = request()
      else
        if vim.fn.confirm('Do you want to change the path to dll?\n' .. vim.g['dotnet_last_dll_path'], '&yes\n&no', 2) == 1 then
          vim.g['dotnet_last_dll_path'] = request()
        end
      end

      return vim.g['dotnet_last_dll_path']
    end

    dap.adapters.coreclr = {
      type = 'executable',
      command = 'C:\\Users\\Mangobyte-LTP-10\\netcoredbg\\netcoredbg.exe',
      args = { '--interpreter=vscode' },
    }

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'launch - netcoredbg',
        request = 'launch',
        program = function()
          if vim.fn.confirm('Should I recompile first?', '&yes\n&no', 2) == 1 then
            vim.g.dotnet_build_project()
          end
          return vim.g.dotnet_get_dll_path()
        end,
      },
      {
        type = 'coreclr',
        name = 'attach - mywebsite',
        request = 'attach',
        processId = function()
          return vim.fn.input 'Process Id '
        end,
        program = function()
          return vim.fn.input('Path to dll', vim.fn.getcwd() .. '\\bin\\Debug\\', 'file')
        end,
      },
    }

    require('mason-nvim-dap').setup {
      automatic_installation = true,

      handlers = {},

      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'netcoredbg',
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', function()
      require('dap').continue()
    end)
    vim.keymap.set('n', '<F10>', function()
      require('dap').step_over()
    end)
    vim.keymap.set('n', '<F11>', function()
      require('dap').step_into()
    end)
    vim.keymap.set('n', '<F12>', function()
      require('dap').step_out()
    end)
    vim.keymap.set('n', '<Leader>b', function()
      require('dap').toggle_breakpoint()
    end)
    vim.keymap.set('n', '<Leader>B', function()
      require('dap').set_breakpoint()
    end)
    vim.keymap.set('n', '<Leader>lp', function()
      require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
    end)
    vim.keymap.set('n', '<Leader>dr', function()
      require('dap').repl.open()
    end)
    vim.keymap.set('n', '<Leader>dl', function()
      require('dap').run_last()
    end)
    vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
      require('dap.ui.widgets').hover()
    end)
    vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
      require('dap.ui.widgets').preview()
    end)
    vim.keymap.set('n', '<Leader>df', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.frames)
    end)
    vim.keymap.set('n', '<Leader>ds', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.scopes)
    end)

    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      mappings = {
        expand = { '<CR>', '<2-LeftMouse>' },
        open = 'o',
        remove = 'd',
        edit = 'e',
        repl = 'r',
        toggle = 't',
      },
      element_mappings = {},
      layouts = {
        {
          elements = {
            -- Elements can be strings or table with id and size keys.
            { id = 'scopes', size = 0.25 },
            'breakpoints',
            'stacks',
            'watches',
          },
          size = 40, -- 40 columns
          position = 'left',
        },
        {
          elements = {
            'repl',
            'console',
          },
          size = 0.25, -- 25% of total lines
          position = 'bottom',
        },
      },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = 'single', -- Border style. Can be "single", "double" or "rounded"
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
      windows = { indent = 1 },
      render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
  end,
}
