return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local dap_python = require("dap-python")

		dap_python.setup("python")

		vim.fn.sign_define("DapBreakpoint", {
			text = "",
			texthl = "DiagnosticSignError",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapBreakpointRejected", {
			text = "", -- or "❌"
			texthl = "DiagnosticSignError",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapStopped", {
			text = "", -- or "→"
			texthl = "DiagnosticSignWarn",
			linehl = "Visual",
			numhl = "DiagnosticSignWarn",
		})

		-- -- Fix the frozen modules issue
		-- vim.schedule(function()
		-- 	if dap.adapters.python then
		-- 	-- Add the frozen modules flag to the existing adapter
		-- 	if dap.adapters.python.args then
		-- 		-- Insert at the beginning of args
		-- 		table.insert(dap.adapters.python.args, 1, '-Xfrozen_modules=off')
		-- 	else
		-- 		dap.adapters.python.args = {'-Xfrozen_modules=off', '-m', 'debugpy.adapter'}
		-- 	end
		-- 	end
		-- end)

		-- Fix the configuration names after nvim-dap-python sets them up
		vim.schedule(function()
			if dap.configurations.python then
				for i, config in ipairs(dap.configurations.python) do
					if config.name == "file" then
						config.name = "Launch current file"
					elseif config.name == "file:args" then
						config.name = "Launch with arguments"
					elseif config.name == "attach" then
						config.name = "Attach to remote"
					elseif config.name == "file:doctest" then
						config.name = "Run doctests"
					end
				end
			end
		end)

		dapui.setup()

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- Keymaps
		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {}) -- Debug current file
		--vim.keymap.set("n", "<leader>dm", dap.test_method, {}) -- Debug current method (unittest)
		--vim.keymap.set("n", "<leader>dk", dapui.toggle, {}) -- Toggle the DAP UI
	end,
}
