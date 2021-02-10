### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 9f135de4-6bf8-11eb-1e50-11fa9e400cf3
using PlutoUI

# ╔═╡ 69f94786-6bf8-11eb-154c-d18b8c8fe404
using Images

# ╔═╡ b31badd0-6bf7-11eb-266b-cb57b725746e
md"""# Pixels and Images
Basic color representation and image composition from data in `juila`.
"""

# ╔═╡ fef6a222-6bf9-11eb-29cb-a1d520ae0ee4
# RGB doc
RGB

# ╔═╡ 08296d10-6bfa-11eb-3883-63c08ff6a729
# N0f8 doc
N0f8

# ╔═╡ eb3416a0-6bf8-11eb-3d95-577363c8e993
# Single pixel
begin
	R, G, B = map(N0f8, (0.0, 0.5, 1.0))
	RGB(R, G, B)
end

# ╔═╡ e2918c06-6bfa-11eb-3c88-7b1e11f50acc


# ╔═╡ Cell order:
# ╟─b31badd0-6bf7-11eb-266b-cb57b725746e
# ╠═9f135de4-6bf8-11eb-1e50-11fa9e400cf3
# ╠═69f94786-6bf8-11eb-154c-d18b8c8fe404
# ╠═fef6a222-6bf9-11eb-29cb-a1d520ae0ee4
# ╠═08296d10-6bfa-11eb-3883-63c08ff6a729
# ╠═eb3416a0-6bf8-11eb-3d95-577363c8e993
# ╠═e2918c06-6bfa-11eb-3c88-7b1e11f50acc
