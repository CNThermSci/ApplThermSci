### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 9f135de4-6bf8-11eb-1e50-11fa9e400cf3
using PlutoUI

# ╔═╡ 69f94786-6bf8-11eb-154c-d18b8c8fe404
using Images

# ╔═╡ f6f40b3c-6c03-11eb-3cbe-c5250ec680ca
using Random

# ╔═╡ b31badd0-6bf7-11eb-266b-cb57b725746e
md"""# Pixels and Colors
Basic color representation and pixel creation in `julia`.
"""

# ╔═╡ eb3416a0-6bf8-11eb-3d95-577363c8e993
# Single pixels ... in a row
begin
	blk = RGB(0, 0, 0)
	whi = RGB(1, 1, 1)
	red = RGB(1, 0, 0)
	gre = RGB(0, 1, 0)
	blu = RGB(0, 0, 1)
	rowImage = [blk whi red gre blu]
end

# ╔═╡ e2918c06-6bfa-11eb-3c88-7b1e11f50acc
typeof(rowImage)

# ╔═╡ c5e72ab2-6bfe-11eb-174c-7b86d6b33741
md"RED level: `r_lvl`"

# ╔═╡ 976c0cf0-6bfb-11eb-28be-df20efdbcb4e
@bind r_lvl Slider(0.0:0.01:1.0, show_value=true)

# ╔═╡ cf4979a2-6bfe-11eb-0821-1dc935dfb277
md"GRE level: `g_lvl`"

# ╔═╡ 84c963e2-6bfe-11eb-01bf-7dccb180503f
@bind g_lvl Slider(0.0:0.01:1.0, show_value=true)

# ╔═╡ d60a0004-6bfe-11eb-232a-ad06afb4692e
md"BLU level: `b_lvl`"

# ╔═╡ 84ca09dc-6bfe-11eb-1ee9-f5023a4cd4ec
@bind b_lvl Slider(0.0:0.01:1.0, show_value=true)

# ╔═╡ 9e6cfe1c-6bfe-11eb-02d7-bf180cf3d54c
[ RGB(r_lvl, g_lvl, b_lvl) Gray(RGB(r_lvl, g_lvl, b_lvl)) ]

# ╔═╡ 926da30e-6bff-11eb-0565-1334ee58a575
md"""# Image from Data
Basic image creation from data
"""

# ╔═╡ 6a8a5acc-6c03-11eb-1397-5fc84ae82bc9
hcat(
	fill(red, (1, 3)),
	fill(gre, (1, 1)),
	fill(blu, (1, 2))
)

# ╔═╡ 36fe3808-6c04-11eb-255c-5ba0ca56c2af
begin
	tmp = hcat(
		fill(blu, (200,  21)),
		fill(whi, (200, 200)),
		fill(red, (200,  79)),
	)
	tmp, shuffle(tmp)
end

# ╔═╡ b00b05d0-6c10-11eb-294b-0da528b5bfed
begin
	save("01-example-01-ordered.png", tmp)
	save("01-example-02-shuffled.png", shuffle(tmp))
end

# ╔═╡ Cell order:
# ╟─b31badd0-6bf7-11eb-266b-cb57b725746e
# ╠═9f135de4-6bf8-11eb-1e50-11fa9e400cf3
# ╠═69f94786-6bf8-11eb-154c-d18b8c8fe404
# ╠═eb3416a0-6bf8-11eb-3d95-577363c8e993
# ╠═e2918c06-6bfa-11eb-3c88-7b1e11f50acc
# ╟─c5e72ab2-6bfe-11eb-174c-7b86d6b33741
# ╟─976c0cf0-6bfb-11eb-28be-df20efdbcb4e
# ╟─cf4979a2-6bfe-11eb-0821-1dc935dfb277
# ╟─84c963e2-6bfe-11eb-01bf-7dccb180503f
# ╟─d60a0004-6bfe-11eb-232a-ad06afb4692e
# ╟─84ca09dc-6bfe-11eb-1ee9-f5023a4cd4ec
# ╠═9e6cfe1c-6bfe-11eb-02d7-bf180cf3d54c
# ╟─926da30e-6bff-11eb-0565-1334ee58a575
# ╠═6a8a5acc-6c03-11eb-1397-5fc84ae82bc9
# ╠═f6f40b3c-6c03-11eb-3cbe-c5250ec680ca
# ╠═36fe3808-6c04-11eb-255c-5ba0ca56c2af
# ╠═b00b05d0-6c10-11eb-294b-0da528b5bfed
