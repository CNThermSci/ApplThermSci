### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ fae18008-6c14-11eb-25b4-9bca6fa35065
using Images

# ╔═╡ 04a4313a-6c15-11eb-0168-05b9b9456127
using Random

# ╔═╡ b529ac22-6c14-11eb-3382-170d7a4cc13a
md"""# Scattered Configuration Generator
Generates images with scattered gas molecules
"""

# ╔═╡ 0776e6f0-6c15-11eb-35db-8ff1771b8d60
BG = RGB(0.0, 0.0, 0.0)

# ╔═╡ 07560926-6c15-11eb-2366-b19e1dbe6538
# Scattered image parameters
imgPars = Dict(
	:col => Dict(
		:_N2 => (RGB(0.2, 0.2, 0.2), 0.78084),
		:_O2 => (RGB(0.2, 0.2, 0.8), 0.209476),
		:_Ar => (RGB(0.2, 0.8, 0.2), 0.00934),
		:CO2 => (RGB(1.0, 0.0, 0.0), 0.000314),
	),
	:sx   => 1920 ÷ 2, # 960,
	:sy   => 1080 ÷ 2, # 540,
	:libf =>    6, # Linear Background Factor: one gas pixel in every (:libf)²
)

# ╔═╡ 07389c56-6c15-11eb-24e9-933d255970a2
begin
	nFact = sum(
		imgPars[:col][K][2]
			for K in keys(imgPars[:col])
	)
	imgSiz = imgPars[:sx] * imgPars[:sy]
	iPixs = Dict(
		K => Int(round(imgPars[:col][K][2] * imgSiz / (nFact * imgPars[:libf]^2)))
			for K in keys(imgPars[:col])
	)
	Diff = imgSiz - sum(values(iPixs))
	#if diff != 0
	#	iPixs[:_N2] -= diff
	#end
	iPixs
end

# ╔═╡ 247c41dc-6c15-11eb-3bc1-b995c9e71748
begin
	IMG = reshape(
		reduce(
			vcat, [
				fill(imgPars[:col][GAS][1], iPixs[GAS])
					for GAS in keys(imgPars[:col])
			],
			init = fill(BG, Diff)
		),
		imgPars[:sy],
		imgPars[:sx]
	)
	save("21-scatrd-01-ordered.png", IMG)
	save("21-scatrd-02-shuffled.png", shuffle(IMG))
end

# ╔═╡ Cell order:
# ╟─b529ac22-6c14-11eb-3382-170d7a4cc13a
# ╠═fae18008-6c14-11eb-25b4-9bca6fa35065
# ╠═04a4313a-6c15-11eb-0168-05b9b9456127
# ╠═0776e6f0-6c15-11eb-35db-8ff1771b8d60
# ╠═07560926-6c15-11eb-2366-b19e1dbe6538
# ╠═07389c56-6c15-11eb-24e9-933d255970a2
# ╠═247c41dc-6c15-11eb-3bc1-b995c9e71748
