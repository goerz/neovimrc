local M = {}

function M.is_git_repo()
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
end

function M.get_git_root()
	local dot_git_path = vim.fn.finddir(".git", ".;")
	return vim.fn.fnamemodify(dot_git_path, ":h")
end

function M.is_subdir(folder, root)
	root = vim.fn.fnamemodify(root, ":p")
	folder = vim.fn.fnamemodify(folder, ":p")
	if not (root:sub(-1) == "/") then
		root = root .. "/"
	end
	if not (folder:sub(-1) == "/") then
		folder = folder .. "/"
	end
	return folder:sub(1, #root) == root
end

-- combine project dir, CWD, and sibling files
function M.find_all_files()
	local _git_root = M.get_git_root()
	local _cwd = vim.fn.getcwd()
	local _filedir = vim.fn.expand("%:p:h")
	local opts = {
		cwd = _cwd,
		search_dirs = { _cwd },
	}
	if M.is_git_repo() then
		if not M.is_subdir(_git_root, _cwd) then
			if M.is_subdir(_cwd, _git_root) then
				opts.search_dirs = { _git_root }
			else
				table.insert(opts.search_dirs, _git_root)
			end
		end
	end
	local _filedir_in_search_dirs = false
	for _, dir in ipairs(opts.search_dirs) do
		if M.is_subdir(_filedir, dir) then
			_filedir_in_search_dirs = true
		end
	end
	if not _filedir_in_search_dirs then
		table.insert(opts.search_dirs, _filedir)
	end
	require("telescope.builtin").find_files(opts)
end

-- find in current project
function M.find_project_files()
	local _git_root = M.get_git_root()
	local _filedir = vim.fn.expand("%:p:h")
	local opts = {
		cwd = _filedir,
	}
	if M.is_git_repo() then
		opts.cwd = _git_root
	end
	require("telescope.builtin").find_files(opts)
end

-- find in folder containing the current file
function M.find_sibling_files()
	local _filedir = vim.fn.expand("%:p:h")
	local opts = {
		cwd = _filedir,
	}
	require("telescope.builtin").find_files(opts)
end

return M
