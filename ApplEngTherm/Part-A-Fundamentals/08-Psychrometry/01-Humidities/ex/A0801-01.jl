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

# ╔═╡ 44780316-7149-11eb-2c22-91b75023501a
using PlutoUI

# ╔═╡ b8e993e0-7149-11eb-1dbb-c52c4563e706
using Unitful

# ╔═╡ 59a271ac-714b-11eb-1167-dd8f89e98540
using PyCall

# ╔═╡ fd91f76e-7147-11eb-04c9-011f7aa335b9
md"""
# Exercício A0801-01 – Massa de vapor d'água em sistema fechado
"""

# ╔═╡ 6dc92e96-7148-11eb-1cc3-cf2d65e8985b
prob = Dict(
	:x => (3.00:0.5:10.00, u"m"),		# Dimensão x, m
	:y => (3.00:0.5:10.00, u"m"),		# Dimensão y, m
	:z => (3.00:0.5:10.00, u"m"),		# Dimensão z, m
	:T => (25.0:1.0:45.00, u"°C"),		# Temperatura, °C
	:P => (80.0:5.0:120.0, u"kPa"),		# Pressão, kPa
	:ϕ => (0.00:0.005:1.0, u"kg/kg"),	# Umidade relativa, %
)

# ╔═╡ b7ce4e48-714a-11eb-3109-27d5146cf744
md"Dimensão x, em $(prob[:x][2])"

# ╔═╡ a25541c0-714a-11eb-21e5-8d9176713369
@bind the_x Slider(prob[:x][1], default=minimum(prob[:x][1]), show_value=true)

# ╔═╡ 561163d6-714b-11eb-048c-77d095a73f07
md"Dimensão y, em $(prob[:y][2])"

# ╔═╡ 5b194bc8-714b-11eb-1461-017e228eb6ae
@bind the_y Slider(prob[:y][1], default=minimum(prob[:y][1]), show_value=true)

# ╔═╡ 5b009d6c-714b-11eb-23a7-b1dac4f0199f
md"Dimensão z, em $(prob[:z][2])"

# ╔═╡ 5ae9231c-714b-11eb-1be0-117d2f7eb9a5
@bind the_z Slider(prob[:z][1], default=minimum(prob[:z][1]), show_value=true)

# ╔═╡ 5ad04798-714b-11eb-205d-6529076d23d6
md"Temperatura T, em $(prob[:T][2])"

# ╔═╡ 5ab790c2-714b-11eb-380a-4348d99eb993
@bind the_T Slider(prob[:T][1], default=minimum(prob[:T][1]), show_value=true)

# ╔═╡ 5a9ba394-714b-11eb-16b1-2fca17e6adb8
md"Pressão P, em $(prob[:P][2])"

# ╔═╡ 5a7fa48c-714b-11eb-31cc-b1f8b9b2794d
@bind the_P Slider(prob[:P][1], default=minimum(prob[:P][1]), show_value=true)

# ╔═╡ 5a62216e-714b-11eb-1014-47f7a212ccf7
md"Umidade relativa ϕ, em %"

# ╔═╡ 5a478110-714b-11eb-3fdc-47936692af9b
@bind the_ϕ Slider(100prob[:ϕ][1], default=maximum(100prob[:ϕ][1]), show_value=true)

# ╔═╡ 780c4238-714d-11eb-034c-ad7e76bd2530
begin
	uni_x = the_x * prob[:x][2]
	uni_y = the_y * prob[:y][2]
	uni_z = the_z * prob[:z][2]
	uni_T = the_T * prob[:T][2]
	uni_P = the_P * prob[:P][2]
	uni_ϕ = the_ϕ * prob[:ϕ][2] / 100.0
	md"(Assigned units to each input parameter)"
end

# ╔═╡ 5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
md"""
## Enunciado:

Uma sala de $(uni_x) × $(uni_y) × $(uni_z) contém ar a $(uni_T) e $(uni_P) a uma umidade relativa de $(100 * uni_ϕ)%. Determine:
(a) a pressão parcial do ar seco;
(b) a umidade específica (absoluta);
(c) a entalpia por unidade de massa de ar seco;
(d) as massas de ar seco e de vapor d'água na sala.
"""

# ╔═╡ 59f6ad1c-714b-11eb-1b85-0542622b8aba
md"""
## Resolução
"""

# ╔═╡ Cell order:
# ╟─fd91f76e-7147-11eb-04c9-011f7aa335b9
# ╠═44780316-7149-11eb-2c22-91b75023501a
# ╠═b8e993e0-7149-11eb-1dbb-c52c4563e706
# ╟─6dc92e96-7148-11eb-1cc3-cf2d65e8985b
# ╟─b7ce4e48-714a-11eb-3109-27d5146cf744
# ╟─a25541c0-714a-11eb-21e5-8d9176713369
# ╟─561163d6-714b-11eb-048c-77d095a73f07
# ╟─5b194bc8-714b-11eb-1461-017e228eb6ae
# ╟─5b009d6c-714b-11eb-23a7-b1dac4f0199f
# ╟─5ae9231c-714b-11eb-1be0-117d2f7eb9a5
# ╟─5ad04798-714b-11eb-205d-6529076d23d6
# ╟─5ab790c2-714b-11eb-380a-4348d99eb993
# ╟─5a9ba394-714b-11eb-16b1-2fca17e6adb8
# ╟─5a7fa48c-714b-11eb-31cc-b1f8b9b2794d
# ╟─5a62216e-714b-11eb-1014-47f7a212ccf7
# ╟─5a478110-714b-11eb-3fdc-47936692af9b
# ╟─780c4238-714d-11eb-034c-ad7e76bd2530
# ╟─5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
# ╟─59f6ad1c-714b-11eb-1b85-0542622b8aba
# ╠═59a271ac-714b-11eb-1167-dd8f89e98540
