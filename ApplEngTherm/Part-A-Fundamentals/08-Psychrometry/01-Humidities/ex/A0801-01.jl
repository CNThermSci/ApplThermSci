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
begin
	CP = pyimport("CoolProp.CoolProp")
	Ra = CP.PropsSI("GAS_CONSTANT",   "air") / CP.PropsSI("M",   "air") * 1.0e-3
	Rv = CP.PropsSI("GAS_CONSTANT", "water") / CP.PropsSI("M", "water") * 1.0e-3
	Cψ = Ra/Rv # Psychrometric constant (usually rounded to 0.622)
	md"Cψ = $(@sprintf(\"%.6f\", Cψ))"
end

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

A pressão parcial do ar seco pode ser determinada via

$P_a = P - P_v,$ onde

$P_v = \phi P_g = \phi P_{sat@T}$
"""

# ╔═╡ 404d04ca-714f-11eb-1850-3d1384e2c747
begin
	Pg = CP.PropsSI("P", "T", the_T + 273.15, "Q", 1.0, "water") * 1.0e-3 # kPa
	Pv = Pg * the_ϕ / 100.0 # kPa
	Pa = the_P - Pv # kPa
	md""" $P_g$, $P_v$, $P_a$ = (
	$(@sprintf(\"%.3f\",Pg)),
	$(@sprintf(\"%.3f\",Pv)),
	$(@sprintf(\"%.3f\",Pa))) kPa
"""
end

# ╔═╡ 161bc6c8-714f-11eb-34d4-798c68a07fe3
md"""
### (b) umidade específica do ar

A umidade específica (absoluta) pode ser determinada via

$\omega = \frac{0,622 P_v}{P - P_v} = \frac{0,622 P_v}{P_a}$
"""

# ╔═╡ a28b7c80-7153-11eb-1e4b-c9655dc6bf11
begin
	ω = 0.622Pv/Pa # kg/kg
	md""" $\omega$ =
	$(@sprintf(\"%.4f\", ω)) kg/kg
	"""
end

# ╔═╡ a2731adc-7153-11eb-0521-5560c819c7a0
md"""
### (c) entalpia do ar por unidade de massa de ar seco

A entalpia do ar por unidade de massa de ar seco é determinada via

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
	md""" $h_a$, $h_v$, $h_g$, $h$ = (
	$(@sprintf(\"%.2f\", ha)), $(@sprintf(\"%.2f\", hv)), $(@sprintf(\"%.2f\", hg)),
	( $(@sprintf(\"%.2f\", h[1])), $(@sprintf(\"%.2f\", h[2])) )) kJ/kg"""
end

# ╔═╡ 6322df58-7169-11eb-2248-4b4bf3689197
md"""
## Solução:

|Letra|Propriedade|Valor|Unid.|
|:---:|:---------:|----:|:----|
|(a)|$P_a$     | $(@sprintf(\"%.2f\",   Pa)) | kPa   |
|(b)|$\omega$  | $(@sprintf(\"%.4f\",    ω)) | kg/kg |
|(c)|$h$       | $(@sprintf(\"%.2f\", h[2])) | kJ/kg |
|(d)|$m_a$     | $(@sprintf(\"%.2f\", h[1])) | kJ/kg |
|(d)|$m_v$     | $(@sprintf(\"%.2f\", h[1])) | kJ/kg |
"""

# ╔═╡ 0e040eaa-7154-11eb-08de-f76fe6ef358b
md"""
#### (d) massas de ar seco e de vapor na sala

Tais massas podem ser calculadas pela equação de estado (de gás ideal):

$m = \frac{PV}{RT}$
"""

# ╔═╡ 778fd34e-716e-11eb-2b04-39e78ece6e49
begin
	the_V = the_x * the_y * the_z
	
	ma = Pa * the_V / (Ra * the_T)
	mv = Pv * the_V / (Rv * the_T)
	
end

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
# ╟─404d04ca-714f-11eb-1850-3d1384e2c747
# ╟─161bc6c8-714f-11eb-34d4-798c68a07fe3
# ╟─a28b7c80-7153-11eb-1e4b-c9655dc6bf11
# ╟─a2731adc-7153-11eb-0521-5560c819c7a0
# ╟─0e85726a-7154-11eb-2ec4-4b45508a285e
# ╟─0e040eaa-7154-11eb-08de-f76fe6ef358b
# ╠═778fd34e-716e-11eb-2b04-39e78ece6e49
