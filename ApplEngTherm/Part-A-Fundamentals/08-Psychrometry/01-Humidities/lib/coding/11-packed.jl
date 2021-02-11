### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 22e74a0a-6c11-11eb-0e3b-9b412bd68889
using Images

# ╔═╡ beafb88c-6c11-11eb-1db3-a362b5c731b5
using Random

# ╔═╡ 58d9c468-6c10-11eb-3a57-37011227cab2
md"""# Packed Configuration Generator
Generates images with packed, image-filling, gas molecules.
"""

# ╔═╡ a8044522-6c10-11eb-2956-a1962daafb60
# Packed image parameters
imgPars = Dict(
	:col => Dict(
		:_N2 => (RGB(0.2, 0.2, 0.2), 0.78084),
		:_O2 => (RGB(0.2, 0.2, 0.8), 0.209476),
		:_Ar => (RGB(0.2, 0.8, 0.2), 0.00934),
		:CO2 => (RGB(1.0, 0.0, 0.0), 0.000314),
	),
	:sx   => 1920 ÷ 2, # 960,
	:sy   => 1080 ÷ 2, # 540,
)

# ╔═╡ a7eebcde-6c10-11eb-2a6a-c78d405f2a79
begin
	nFact = sum(
		imgPars[:col][K][2]
			for K in keys(imgPars[:col])
	)
	imgSiz = imgPars[:sx] * imgPars[:sy]
	iPixs = Dict(
		K => Int(round(imgPars[:col][K][2] * imgSiz / nFact))
			for K in keys(imgPars[:col])
	)
	diff = sum(values(iPixs)) - imgSiz
	if diff != 0
		iPixs[:_N2] -= diff
	end
	iPixs
end

# ╔═╡ a7ba27c4-6c10-11eb-2bcf-b985862fd13a
begin
	IMG = reshape(
		reduce(
			vcat, [
				fill(imgPars[:col][GAS][1], iPixs[GAS])
					for GAS in keys(imgPars[:col])
			]
		),
		imgPars[:sy],
		imgPars[:sx]
	)
	save("11-packed-01-ordered.png", IMG)
	save("11-packed-02-shuffled.png", shuffle(IMG))
end

# ╔═╡ Cell order:
# ╟─58d9c468-6c10-11eb-3a57-37011227cab2
# ╠═22e74a0a-6c11-11eb-0e3b-9b412bd68889
# ╠═beafb88c-6c11-11eb-1db3-a362b5c731b5
# ╠═a8044522-6c10-11eb-2956-a1962daafb60
# ╠═a7eebcde-6c10-11eb-2a6a-c78d405f2a79
# ╠═a7ba27c4-6c10-11eb-2bcf-b985862fd13a
