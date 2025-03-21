local has_telescope, telescope = pcall(require, "telescope")
local node_packages = require("telescope-node-packages")

if not has_telescope then
	vim.notify("Telescope is not install", vim.log.levels.ERROR, { title = "Telescope Node Packages" })
end

return telescope.register_extension({
	exports = {
		node_packages = node_packages.start,
	},
})
