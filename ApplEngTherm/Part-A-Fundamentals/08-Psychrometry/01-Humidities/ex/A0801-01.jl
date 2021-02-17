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

# ╔═╡ 59a271ac-714b-11eb-1167-dd8f89e98540
using PyCall

# ╔═╡ fd91f76e-7147-11eb-04c9-011f7aa335b9
md"""
# Exercício A0801-01 – Massa de vapor d'água em sistema fechado
"""

# ╔═╡ 6dc92e96-7148-11eb-1cc3-cf2d65e8985b
prob = Dict(
	:x => 3.00:0.5:10.00,	# Dimensão x, m
	:y => 3.00:0.5:10.00,	# Dimensão y, m
	:z => 3.00:0.5:10.00,	# Dimensão z, m
	:T => 25.0:1.0:45.00,	# Temperatura, °C
	:P => 80.0:5.0:120.0,	# Pressão, kPa
	:ϕ => 0.00:5.0:100.0,	# Umidade relativa, %
)

# ╔═╡ b7ce4e48-714a-11eb-3109-27d5146cf744
md"Dimensões x, y, e z, em m"

# ╔═╡ a25541c0-714a-11eb-21e5-8d9176713369
@bind the_x Slider(prob[:x], default=minimum(prob[:x]), show_value=true)

# ╔═╡ 5b194bc8-714b-11eb-1461-017e228eb6ae
@bind the_y Slider(prob[:y], default=minimum(prob[:y]), show_value=true)

# ╔═╡ 5ae9231c-714b-11eb-1be0-117d2f7eb9a5
@bind the_z Slider(prob[:z], default=minimum(prob[:z]), show_value=true)

# ╔═╡ 5ad04798-714b-11eb-205d-6529076d23d6
md"Temperatura T, em °C"

# ╔═╡ 5ab790c2-714b-11eb-380a-4348d99eb993
@bind the_T Slider(prob[:T], default=minimum(prob[:T]), show_value=true)

# ╔═╡ 5a9ba394-714b-11eb-16b1-2fca17e6adb8
md"Pressão P, em kPa"

# ╔═╡ 5a7fa48c-714b-11eb-31cc-b1f8b9b2794d
@bind the_P Slider(prob[:P], default=minimum(prob[:P]), show_value=true)

# ╔═╡ 5a62216e-714b-11eb-1014-47f7a212ccf7
md"Umidade relativa ϕ, em %"

# ╔═╡ 5a478110-714b-11eb-3fdc-47936692af9b
@bind the_ϕ Slider(prob[:ϕ], default=maximum(prob[:ϕ][7]), show_value=true)

# ╔═╡ 5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
md"""
## Enunciado:

Uma sala de $(the_x)m × $(the_y)m × $(the_z)m contém ar a $(the_T)°C e $(the_P)kPa a uma umidade relativa de $(the_ϕ)%. Determine:

(a) a pressão parcial do ar seco;
(b) a umidade específica (absoluta);
(c) a entalpia por unidade de massa de ar seco;
(d) as massas de ar seco e de vapor d'água na sala.
"""

# ╔═╡ 59f6ad1c-714b-11eb-1b85-0542622b8aba
md"""
## Resolução
"""

# ╔═╡ 82207d6a-714e-11eb-302e-812ad2d704dd
CP = pyimport("CoolProp.CoolProp")

# ╔═╡ 40fff3aa-714f-11eb-0209-1d7ba5d8572f
md"""
(a) A pressão parcial do ar seco pode ser determinada via

$P_a = P - P_v,$

onde

$P_v = \phi P_g = \phi P_{sat@T}$.
"""

# ╔═╡ 404d04ca-714f-11eb-1850-3d1384e2c747
Pg = uconvert(
	u"kPa",
	CP.PropsSI(
		"P",
		"T", float(uconvert(u"K", uni_T).val),
		"Q", 1.0,
		"water"
	) * u"Pa"
)

# ╔═╡ 6bac14d2-7150-11eb-1033-0d87d6791f79
Pv = uni_ϕ * Pg

# ╔═╡ 402def7c-714f-11eb-1311-ed5bef212eac


# ╔═╡ de7d75cc-714e-11eb-050f-ab2c0d27961d
st1 = CP.State("water", Dict("P" => 100.0, "Q" => 1.0))

# ╔═╡ 1640a90a-714f-11eb-28d1-5db33840373a
st1.s

# ╔═╡ 161bc6c8-714f-11eb-34d4-798c68a07fe3


# ╔═╡ Cell order:
# ╟─fd91f76e-7147-11eb-04c9-011f7aa335b9
# ╠═44780316-7149-11eb-2c22-91b75023501a
# ╟─6dc92e96-7148-11eb-1cc3-cf2d65e8985b
# ╠═b7ce4e48-714a-11eb-3109-27d5146cf744
# ╟─a25541c0-714a-11eb-21e5-8d9176713369
# ╟─5b194bc8-714b-11eb-1461-017e228eb6ae
# ╟─5ae9231c-714b-11eb-1be0-117d2f7eb9a5
# ╟─5ad04798-714b-11eb-205d-6529076d23d6
# ╟─5ab790c2-714b-11eb-380a-4348d99eb993
# ╟─5a9ba394-714b-11eb-16b1-2fca17e6adb8
# ╟─5a7fa48c-714b-11eb-31cc-b1f8b9b2794d
# ╟─5a62216e-714b-11eb-1014-47f7a212ccf7
# ╟─5a478110-714b-11eb-3fdc-47936692af9b
# ╟─5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
# ╟─59f6ad1c-714b-11eb-1b85-0542622b8aba
# ╠═59a271ac-714b-11eb-1167-dd8f89e98540
# ╠═82207d6a-714e-11eb-302e-812ad2d704dd
# ╟─40fff3aa-714f-11eb-0209-1d7ba5d8572f
# ╠═404d04ca-714f-11eb-1850-3d1384e2c747
# ╠═6bac14d2-7150-11eb-1033-0d87d6791f79
# ╠═402def7c-714f-11eb-1311-ed5bef212eac
# ╠═de7d75cc-714e-11eb-050f-ab2c0d27961d
# ╠═1640a90a-714f-11eb-28d1-5db33840373a
# ╠═161bc6c8-714f-11eb-34d4-798c68a07fe3
