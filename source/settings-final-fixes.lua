--if settings.global.log_master == nil then

	data:extend(
	{
		{
			type = "bool-setting",
			name = "log_master",
			setting_type = "runtime-global",
			order = "z1",
			default_value = false,
		},
		{
			type = "int-setting",
			name = "log_level",
			setting_type = "runtime-global",
			order = "z2",
			default_value = 3,
	    minimum_value = 1,
	    maximum_value = 3
		},
		{
			type = "bool-setting",
			name = "log_player_logging",
			setting_type = "runtime-global",
			order = "z3",
			default_value = true,
		},
		{
			type = "bool-setting",
			name = "log_stack_trace",
			setting_type = "runtime-global",
			order = "z4",
			default_value = true,
		}
	})

--end