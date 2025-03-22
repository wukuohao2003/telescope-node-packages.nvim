local M = {}
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local Job = require("plenary.job")

local function get_package_json_path()
	local current_dir = vim.fn.getcwd()
	local package_json_path = current_dir .. "/package.json"
	if vim.fn.filereadable(package_json_path) == 1 then
		return package_json_path
	end
	return nil
end

local function get_installed_packages()
	local package_json_path = get_package_json_path()
	if not package_json_path then
		return {}
	end
	local package_json = vim.fn.json_decode(vim.fn.readfile(package_json_path))
	local dependencies = package_json.dependencies or {}
	local devDependencies = package_json.devDependencies or {}
	local packages = {}
	for name, _ in pairs(dependencies) do
		table.insert(packages, name)
	end
	for name, _ in pairs(devDependencies) do
		table.insert(packages, name)
	end
	return packages
end

local args = function(command, package_name)
	if command == "yarn" then
		return {
			remove = { "remove", package_name },
			install = { "add", package_name },
		}
	elseif command == "pnpm" then
		return {
			remove = { "remove", package_name },
			install = { "add", package_name },
		}
	else
		return {
			remove = { "uninstall", package_name },
			install = { "install", package_name },
		}
	end
end

local function remove_package(package_name)
	local package_json_path = get_package_json_path()
	if not package_json_path then
		vim.notify(
			"No package.json file found in the current directory",
			vim.log.levels.WARN,
			{ title = "Telescope Node Packages" }
		)
		return
	end
	local package_json = vim.fn.json_decode(vim.fn.readfile(package_json_path))
	local command
	if not package_json.node_packages or not package_json.node_packages.command then
		vim.notify(
			"No package manager found in package.json",
			vim.log.levels.ERROR,
			{ title = "Telescope Node Packages" }
		)
		return
	else
		command = package_json.node_packages.command
	end
	local args_cmd = args(command, package_name)
	Job:new({
		command = command,
		args = args_cmd.remove,
		on_exit = function(_, return_val)
			if return_val == 0 then
				vim.notify(
					"Package " .. package_name .. " removed successfully",
					vim.log.levels.INFO,
					{ title = "Telescope Node Packages" }
				)
				return true
			else
				vim.notify(
					"Failed to remove package " .. package_name,
					vim.log.levels.WARN,
					{ title = "Telescope Node Packages" }
				)
				return false
			end
		end,
	}):start()
end

local function install_packages(package_names)
	local package_json_path = get_package_json_path()
	if not package_json_path then
		vim.notify(
			"No package.json file found in the current directory",
			vim.log.levels.WARN,
			{ title = "Telescope Node Packages" }
		)
		return
	end
	local package_json = vim.fn.json_decode(vim.fn.readfile(package_json_path))
	local command
	if not package_json.node_packages or not package_json.node_packages.command then
		vim.notify(
			"No package manager found in package.json",
			vim.log.levels.WARN,
			{ title = "Telescope Node Packages" }
		)
		return
	else
		command = package_json.node_packages.command
	end
	local package_include = string.find(package_names, ",", 1, true) ~= nil
	local packages
	if package_include then
		packages = { package_names }
	else
		packages = vim.split(package_names, ",", { trimempty = true })
	end
	for _, package_name in ipairs(packages) do
		local args_cmd = args(command, package_name)
		Job:new({
			command = command,
			args = args_cmd.install,
			on_exit = function(_, return_val)
				if return_val == 0 then
					vim.notify(
						"Package " .. package_name .. " installed successfully",
						vim.log.levels.INFO,
						{ title = "Telescope Node Packages" }
					)
					return true
				else
					vim.notify(
						"Failed to install package " .. package_name,
						vim.log.levels.ERROR,
						{ title = "Telescope Node Packages" }
					)
					return false
				end
			end,
		}):start()
	end
end

function M.start()
	local package_json_path = get_package_json_path()
	if not package_json_path then
		vim.notify(
			"No package.json file found in the current directory",
			vim.log.levels.WARN,
			{ title = "Telescope Node Packages" }
		)
		return
	end

	local packages = get_installed_packages()
	pickers
		.new({}, {
			prompt_title = "Node Packages Manager",
			finder = finders.new_table({
				results = packages,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(_, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					if selection then
						local remove_status = remove_package(selection[1])
						if remove_status then
							table.insert(packages, selection[1])
							pickers.refresh()
						end
					end
				end)

				map("i", "<CR>", function()
					local input = action_state.get_current_line()
					if input and #input > 0 then
						local install_status = install_packages(input)
						if install_status then
							table.insert(packages, input)
							pickers.refresh()
						end
					else
						vim.notify(
							"The package name cannot be empty",
							vim.log.levels.WARN,
							{ title = "Telescope Node Packages" }
						)
					end
				end)

				return true
			end,
		})
		:find()
end

return M
