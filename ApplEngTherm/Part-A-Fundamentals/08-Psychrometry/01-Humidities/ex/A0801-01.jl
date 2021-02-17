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
begin
	using PlutoUI
	using PyCall
	using Printf
end

# ╔═╡ 82207d6a-714e-11eb-302e-812ad2d704dd
CP = pyimport("CoolProp.CoolProp");

# ╔═╡ fd91f76e-7147-11eb-04c9-011f7aa335b9
md"""
# Exercício A0801-01 – Massa de vapor d'água em sistema fechado
"""

# ╔═╡ 6dc92e96-7148-11eb-1cc3-cf2d65e8985b
begin
	the_x, the_y, the_z = 3.0, 3.0, 3.0
	prob = Dict(
		:T => 25.0:1.0:45.00,	# Temperatura, °C
		:P => 80.0:5.0:120.0,	# Pressão, kPa
		:ϕ => 0.00:5.0:100.0,	# Umidade relativa, %
	)
end

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
### (a) pressão parcial do ar seco
"""

# ╔═╡ 40fff3aa-714f-11eb-0209-1d7ba5d8572f
md"""
(a) A pressão parcial do ar seco pode ser determinada via

$P_a = P - P_v,$ onde

$P_v = \phi P_g = \phi P_{sat@T}$
"""

# ╔═╡ 404d04ca-714f-11eb-1850-3d1384e2c747
Pg = CP.PropsSI(
		"P",
		"T", the_T + 273.15,
		"Q", 1.0,
		"water"
	) * 1.0e-3 # kPa

# ╔═╡ 6bac14d2-7150-11eb-1033-0d87d6791f79
Pv = Pg * the_ϕ / 100.0 # kPa

# ╔═╡ 402def7c-714f-11eb-1311-ed5bef212eac
Pa = the_P - Pv # kPa

# ╔═╡ 161bc6c8-714f-11eb-34d4-798c68a07fe3
md"""
(b) A umidade específica (absoluta) do ar pode ser determinada via

$\omega = \frac{0,622 P_v}{P - P_v} = \frac{0,622 P_v}{P_a}$
"""

# ╔═╡ a28b7c80-7153-11eb-1e4b-c9655dc6bf11
ω = 0.622Pv/Pa

# ╔═╡ a2731adc-7153-11eb-0521-5560c819c7a0
md"""
(c) a entalpia do ar por unidade de massa de ar seco é determinada via

$h = h_a + \omega h_v \approx c_P\mathsf{T} + \omega h_g$
"""

# ╔═╡ 0e85726a-7154-11eb-2ec4-4b45508a285e
begin
	cp = 1.005 # kJ/kg⋅°C
	ha = cp * the_T # kJ/kg
	stv = CP.State("water", Dict("P"=>Pv, "T"=>the_T+273.15))
	stg = CP.State("water", Dict("Q"=>1.0, "T"=>the_T+273.15))
	hv = stv.h
	hg = stg.h
	h = (ha + ω*hv, ha + ω*hg)
	md"""
	|Propriedade|Valor|
	|:--------:|---------------:|
	|ha        | $(round(ha, digits=2)) kJ/kg    |
	|hg        | $(round(hg, digits=2)) kJ/kg    |
	|hv        | $(round(hv, digits=2)) kJ/kg    |
	|h (exato) | $(round(h[1], digits=2)) kJ/kg  |
	|h (aprox) | $(round(h[2], digits=2)) kJ/kg  |
	"""
end

# ╔═╡ 6322df58-7169-11eb-2248-4b4bf3689197
md"""
## Solução:

|Letra|Propriedade|Valor|
|:---:|:---------:|----:|
|(a)|$P_a$     | $(@sprintf("%.2f", Pa)) kPa   |
|(b)|$\omega$  | $(@sprintf("%.4f",  ω)) kg/kg |
|(c)|$h$       | $(@sprintf("%.2f",  h)) kJ/kg |
|(d)|$h$       | $(@sprintf("%.2f",  h)) kJ/kg |
"""

# ╔═╡ 0e040eaa-7154-11eb-08de-f76fe6ef358b


# ╔═╡ Cell order:
# ╠═44780316-7149-11eb-2c22-91b75023501a
# ╠═82207d6a-714e-11eb-302e-812ad2d704dd
# ╟─fd91f76e-7147-11eb-04c9-011f7aa335b9
# ╟─6dc92e96-7148-11eb-1cc3-cf2d65e8985b
# ╟─5ad04798-714b-11eb-205d-6529076d23d6
# ╟─5ab790c2-714b-11eb-380a-4348d99eb993
# ╟─5a9ba394-714b-11eb-16b1-2fca17e6adb8
# ╟─5a7fa48c-714b-11eb-31cc-b1f8b9b2794d
# ╟─5a62216e-714b-11eb-1014-47f7a212ccf7
# ╟─5a478110-714b-11eb-3fdc-47936692af9b
# ╟─5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
# ╟─6322df58-7169-11eb-2248-4b4bf3689197
# ╟─59f6ad1c-714b-11eb-1b85-0542622b8aba
# ╟─40fff3aa-714f-11eb-0209-1d7ba5d8572f
# ╠═404d04ca-714f-11eb-1850-3d1384e2c747
# ╠═6bac14d2-7150-11eb-1033-0d87d6791f79
# ╠═402def7c-714f-11eb-1311-ed5bef212eac
# ╟─161bc6c8-714f-11eb-34d4-798c68a07fe3
# ╠═a28b7c80-7153-11eb-1e4b-c9655dc6bf11
# ╟─a2731adc-7153-11eb-0521-5560c819c7a0
# ╠═0e85726a-7154-11eb-2ec4-4b45508a285e
# ╠═0e040eaa-7154-11eb-08de-f76fe6ef358b
