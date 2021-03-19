### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 44780316-7149-11eb-2c22-91b75023501a
begin
	using PlutoUI
	using PyCall
	CP = pyimport("CoolProp.CoolProp")
	using Printf
	using Plots
end

# ╔═╡ 570e1fe8-7206-11eb-29d3-e1b68516ba96
html"""
<table style="width:100%">
  <tr>
    <td style="width:100px"><img src="https://github.com/CNThermSci/ApplThermSci/raw/master/00-res/logo/CNThermSci-logo-A.png" alt="CNThermSci" style="width:100px"></td>
    <td>
      <b>Prof. C. Naaktgeboren, PhD</b>
      <br>https://github.com/CNThermSci/ApplThermSci<br>
      <small>This example is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons BY-NC-SA License</a>.</small>
    </td>
    <td style="width:125px"><img src="https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png" alt="CC-BY-NC-SA" style="width:125px"></td>
  </tr>
</table>
"""

# ╔═╡ 056da550-71fc-11eb-3940-5d1996cf5ec2
md"""
# B04 – Ciclos de Refrigeração

## 01 – Ciclos de Refrigeração por Compressão de Vapor de Simples Estágio

### Exemplo `B0401-01` – Ciclo de Refrigeração por Compressão de Vapor de Simples Estágio

Original.
"""

# ╔═╡ 6dc92e96-7148-11eb-1cc3-cf2d65e8985b
begin
	the_x, the_y, the_z = 11.5, 11.5, 6.0
	prob = Dict(
		:T => 15.0:1.0:60.00,	# Temperatura, °C
		:P => 80.0:5.0:120.0,	# Pressão, kPa
		:ϕ => 15.0:5.0:100.0,	# Umidade relativa, %
	)
end

# ╔═╡ 5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
md"""
## Enunciado:

![](https://github.com/CNThermSci/ApplThermSci/raw/master/ApplEngTherm/Part-B-Applications/04-Refrigeration/01-VaporCompr/fig/0002-Refr-Vap-RE.png)

Determine: **(a)** a pressão parcial do ar seco; **(b)** a umidade específica (absoluta); **(c)** a entalpia por unidade de massa de ar seco; **(d)** as massas de ar seco e de vapor d'água no galpão.
"""

# ╔═╡ 6322df58-7169-11eb-2248-4b4bf3689197
md"""
## Solução:

|Letra|Propriedade|Valor|Unid.|
|:---:|:---------:|----:|:----|
|(a)|$P_a$     | $(@sprintf(\"%.2f\",   Pa)) | kPa   |
|(b)|$\omega$  | $(@sprintf(\"%.4f\",    ω)) | kg/kg |
|(c)|$h$       | $(@sprintf(\"%.2f\", h[2])) | kJ/kg |
|(d)|$m_a$     | $(@sprintf(\"%.2f\",   ma)) | kg |
|(d)|$m_v$     | $(@sprintf(\"%.2f\",   mv)) | kg |
"""

# ╔═╡ 59f6ad1c-714b-11eb-1b85-0542622b8aba
md"""
## Resolução

### (a) pressão parcial do ar seco

A pressão parcial do ar seco é determinada via

$P_a = P - P_v,$ onde

$P_v = \phi P_g = \phi P_{sat@T},$

e $P_{sat@T}$ é obtida por meio da biblioteca [CoolProp](http://www.coolprop.org/index.html) via [Pycall.jl](https://github.com/JuliaPy/PyCall.jl).
"""

# ╔═╡ 96c9b986-717e-11eb-21d0-5d3bdcdaf318
md"""
## Bibliotecas e Demais Recursos
"""

# ╔═╡ 0a3b27a8-71fa-11eb-32c4-517738939197
md"""
### Bibliotecas
"""

# ╔═╡ f96141a6-71f9-11eb-065a-69b0f4594921
md"""
### Gráfico - Domo de Saturação da Água
"""

# ╔═╡ b4b97260-717e-11eb-25c3-ffcd02a2662e
begin
	# Basic constants
	FL = "water"
	TT = CP.PropsSI("Ttriple", FL)
	TC = CP.PropsSI("Tcrit", FL)
	TSTL = (TT, CP.PropsSI("S", "T", TT, "Q", 0.0, FL))
	TSTV = (TT, CP.PropsSI("S", "T", TT, "Q", 1.0, FL))
	TSCR = (TC, CP.PropsSI("S", "T", TC, "Q", 0.5, FL))
	# Saturation dome
	N = range(0.0, stop=1.0, length=20)
	P = 1.0 .- (1.0 .- N).^2
	tLiq = TT .+ (TC - TT) .* P
	tVap = reverse(tLiq)[2:end]
	sLiq = [CP.PropsSI("S", "T", _t, "Q", 0.0, FL) for _t in tLiq] .* 1.0e-3
	sVap = [CP.PropsSI("S", "T", _t, "Q", 1.0, FL) for _t in tVap] .* 1.0e-3
	DOME = (cat(tLiq, tVap, dims=1).-273.15, cat(sLiq, sVap, dims=1))
end;

# ╔═╡ 98a9cb5c-7187-11eb-08f2-d53ad216d48e
begin
	# Isobar @ Pv
	if Pv > minP
		_P = plot(DOME[2], DOME[1], lw=3, size=(320, 180), legend=false)
		PO = CP.PropsSI("T", "P", Pv * 1.0e+3, "Q", 0.0, FL)
		OL = (PO, CP.PropsSI("S", "P", Pv * 1.0e+3, "Q", 0.0, FL) * 1.0e-3)
		OV = (PO, CP.PropsSI("S", "P", Pv * 1.0e+3, "Q", 1.0, FL) * 1.0e-3)
		tIso = range(PO, stop=TC, length=10)[2:end]
		sIso = [CP.PropsSI("S", "T", _t, "P", Pv * 1.0e+3, FL)
			for _t in tIso] .* 1.0e-3
		ISOP = (
			cat([OL[1], OV[1]], tIso, dims=1).-273.15,
			cat([OL[2], OV[2]], sIso, dims=1))
		plot!(_P, ISOP[2], ISOP[1], lw=1)		
		# Water vapor state
		if the_ϕ < 100.0
			plot!(_P,
				[CP.PropsSI("S", "T", the_T+273.15, "P", Pv*1.0e+3, FL)] .* 1.0e-3,
				[the_T],
				marker = (:hexagon, 2, 0.6, :green, stroke(3, 0.2, :black, :dot))
			)
		else
			plot!(_P,
				[CP.PropsSI("S", "T", the_T+273.15, "Q", 1.0, FL)] .* 1.0e-3,
				[the_T],
				marker = (:hexagon, 2, 0.6, :green, stroke(3, 0.2, :black, :dot))
			)
		end
	else
		_P = plot(DOME[2], DOME[1], lw=3, size=(300, 200), legend=false)
	end
	savefig("A0801-01.svg")
	_P
end

# ╔═╡ Cell order:
# ╟─570e1fe8-7206-11eb-29d3-e1b68516ba96
# ╟─056da550-71fc-11eb-3940-5d1996cf5ec2
# ╟─6dc92e96-7148-11eb-1cc3-cf2d65e8985b
# ╠═98a9cb5c-7187-11eb-08f2-d53ad216d48e
# ╠═5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
# ╠═6322df58-7169-11eb-2248-4b4bf3689197
# ╠═59f6ad1c-714b-11eb-1b85-0542622b8aba
# ╟─96c9b986-717e-11eb-21d0-5d3bdcdaf318
# ╟─0a3b27a8-71fa-11eb-32c4-517738939197
# ╠═44780316-7149-11eb-2c22-91b75023501a
# ╟─f96141a6-71f9-11eb-065a-69b0f4594921
# ╠═b4b97260-717e-11eb-25c3-ffcd02a2662e
