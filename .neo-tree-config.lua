return function(opts)
	table.insert(opts.filesystem.filtered_items.hide_by_name, ".elixir_ls")
	table.insert(opts.filesystem.filtered_items.hide_by_name, "_build")
	table.insert(opts.filesystem.filtered_items.hide_by_name, "deps")
	table.insert(opts.filesystem.filtered_items.hide_by_name, "mix.lock")

	return opts
end
