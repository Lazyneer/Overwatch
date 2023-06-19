function LoadFonts()
	surface.CreateFont("Overwatch.ObjectiveTitle", {
		font = "Segoe UI Black",
		size = 24
	})

	surface.CreateFont("Overwatch.Objective", {
		font = "Arial",
		size = 20
	})

	surface.CreateFont("Overwatch.Indicator", {
		font = "Arial",
		size = 16
	})

	surface.CreateFont("Overwatch.Menu", {
		font = "Verdana",
		size = 20
	})

	surface.CreateFont("Overwatch.MenuTitle", {
		font = "Verdana",
		size = 40,
		weight = 800,
		italic = true
	})

	surface.CreateFont("Overwatch.MenuSubTitle", {
		font = "Verdana",
		size = 30,
		weight = 800,
		italic = true
	})

	surface.CreateFont("Overwatch.MenuBold", {
		font = "Verdana",
		size = 16,
		weight = 800,
	})

	surface.CreateFont("Overwatch.MenuHelp", {
		font = "Verdana",
		size = 16
	})

	surface.CreateFont("Overwatch.Scoreboard", {
		font	= "Helvetica",
		size	= 22,
		weight	= 800
	})

	surface.CreateFont("Overwatch.ScoreboardTitle", {
		font	= "Helvetica",
		size	= 32,
		weight	= 800
	})

	surface.CreateFont("Overwatch.ScoreboardFooter", {
		font	= "Helvetica",
		size	= 16,
		weight	= 800
	})

	surface.CreateFont("Overwatch.TimerTitle", {
		font = "Verdana",
		size = 16
	})

	surface.CreateFont("Overwatch.Verdana", {
		font = "Verdana",
		size = 20 * hudScale,
		additive = true
	})

	surface.CreateFont("Overwatch.VerdanaBold", {
		font = "Verdana",
		size = 20 * hudScale,
		weight = 700,
		additive = true
	})

	surface.CreateFont("Overwatch.Number", {
		font = "HalfLife2",
		size = 70 * hudScale,
		additive = true
	})

	surface.CreateFont("Overwatch.NumberGlow", {
		font = "HalfLife2",
		size = 70 * hudScale,
		blursize = 8,
		scanlines = 2,
		additive = true
	})

	surface.CreateFont("Overwatch.NumberSmall", {
		font = "HalfLife2",
		size = 36 * hudScale,
		weight = 700,
		additive = true
	})

	surface.CreateFont("Overwatch.Objectives", {
		font = "DermaLarge",
		size = 20 * hudScale,
		additive = true
	})

	surface.CreateFont("Overwatch.Timer", {
		font = "Verdana",
		size = 30 * hudScale,
		weight = 700,
		additive = true
	})

	surface.CreateFont("Overwatch.TimerGlow", {
		font = "Verdana",
		size = 30 * hudScale,
		weight = 700,
		blursize = 6,
		scanlines = 2,
		additive = true
	})

	surface.CreateFont("Overwatch.Health", {
		font = "Arial",
		size = 160
	})
end

LoadFonts()