local M = {}

function M.setup(opts)
	opts = opts or {}
	vim.g.mapleader = " "

	vim.keymap.set("n", "<leader>ms", function()
		show_mark()
	end, { desc = "MarkusDisplay" })

	vim.keymap.set("n", "<leader>mc", function()
		choose_mark()
	end, { desc = "MarkusChoose" })

	vim.keymap.set("n", "<leader>md", function()
		delete_marks()
	end, { desc = "MarkusDelete" })

	vim.keymap.set("n", "<leader>mx", function()
		select_delete_mark()
	end, { desc = "MarkusSelectDelete" })
end

function get_marks()
	local command = "marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	if pcall(function()
				vim.api.nvim_exec2(command, { output = true })
			end) then
		local result = vim.api.nvim_exec2(command, { output = true })
		local output_string = result.output
		local lines = vim.split(output_string, "\n")
		return lines
	else
		return { "no marks set" }
	end
end

function choose_mark()
	local buffer = buffer()
	vim.fn.prompt_setprompt(buffer, "Choose mark: ")
	vim.fn.prompt_setcallback(buffer, function(input)
		if input == "" then
			return
		end

		local command = "'" .. input
		local win_id = vim.api.nvim_get_current_win()
		vim.api.nvim_win_close(win_id, true)
		pcall(vim.cmd(command))
	end)

	-- 3. Define floating window options
	window_manager(buffer)
end

function show_mark()
	local buffer = buffer()
	window_manager(buffer)
end

function buffer()
	local marks = get_marks()
	local bufnr = vim.api.nvim_create_buf(false, true)
	-- nvim_buf_set_lines(buffer, start, end, strict_indexing, {lines})
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, marks)
	vim.api.nvim_buf_set_option(bufnr, "buftype", "prompt")
	return bufnr
end

function delete_marks()
	local buffer = buffer()
	vim.fn.prompt_setprompt(buffer, "delete all marks? Y/N")
	vim.fn.prompt_setcallback(buffer, function(input)
		local win_id = vim.api.nvim_get_current_win()
		if input == "N" then
			vim.api.nvim_win_close(win_id, true)
		elseif input == "Y" then
			local command = "delmarks A-Z"
			pcall(vim.cmd(command))
			vim.api.nvim_win_close(win_id, true)
		end
	end)
	window_manager(buffer)
end

-- if pcall(function()
-- 			vim.api.nvim_exec2(command, { output = true })
-- 		end) then
-- 	local result = vim.api.nvim_exec2(command, { output = true })
-- 	local output_string = result.output
-- 	local lines = vim.split(output_string, "\n")
-- 	return lines
-- else
-- 	return { "no marks set" }
-- end

function select_delete_mark()
	local buffer = buffer()
	vim.fn.prompt_setprompt(buffer, "which mark to delete?")
	vim.fn.prompt_setcallback(buffer, function(input)
		local win_id = vim.api.nvim_get_current_win()
		if pcall(function()
					local command = "delmark " .. input
					vim.cmd(command)
				end) then
			local command = "delmark " .. input
			vim.cmd(command)
		else
			return { "please select a valid mark" }
		end
		vim.api.nvim_win_close(win_id, true)
	end)
	window_manager(buffer)
end

function window_manager(buffer)
	local width = 80
	local height = 20
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2, -- Center horizontally
		row = (vim.o.lines - height) / 2, -- Center vertically
		style = "minimal",               -- Removes line numbers, etc.
		border = "rounded",
	}
	vim.api.nvim_open_win(buffer, true, opts)
end

return M
