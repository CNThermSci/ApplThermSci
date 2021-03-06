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
	CP = pyimport("CoolProp.CoolProp")
	using Printf
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
prob = Dict(
	:WC	=>	  1.0:	0.25:	 3.0,	# Taxa de trabalho, kW
	:ηC	=>	 75.0:	5.00:	90.0,	# Eficiência isentrópica, %
	:IC	=>	 50.0:	5.00:	75.0,	# Irrev. perdida no compressor, %
	:Tc	=>	 60.0:	5.00:	80.0,	# Temperatura de condensação, °C
	:Te	=>	-20.0:	5.00:	-5.0,	# Temperatura de evaporação, °C
);

# ╔═╡ 72413c5a-88f4-11eb-08d2-813542bed0f4
@bind go Button("Recompute")

# ╔═╡ 7b557108-88f4-11eb-386c-5de9519fa60a
if go == "Recompute"
	the = Dict(
	   K => rand(prob[K])
		   for K in keys(prob)
	)
end

# ╔═╡ 5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
md"""
## Enunciado:

Um ciclo de refrigeração por compressão de vapor, ilustrado abaixo, opera com entrada de potência de **$(the[:WC])kW** no compressor, o qual possui eficiência isentrópica de **$(the[:ηC])%** e perde **$(the[:IC])%** da taxa de irreversibilidade na forma de calor para o meio, conforme indicado. A temperatura de condensação é de **$(the[:Tc])°C** e a de evaporação é de **$(the[:Te])°C**. Determine, considerando o emprego do **R134a**:

![](https://github.com/CNThermSci/ApplThermSci/raw/master/ApplEngTherm/Part-B-Applications/04-Refrigeration/01-VaporCompr/fig/0002-Refr-Vap-RE.png)

**(a)** A vazão mássica de refrigerante, em kg/s

**(b)** A taxa de rejeição de calor (no condensador), em kW

**(c)** A capacidade de refrigeração, em ton

**(d)** O COP do refrigerador, em %
"""

# ╔═╡ 59f6ad1c-714b-11eb-1b85-0542622b8aba
md"""
## Resolução

Escreve-se uma função que resolve o ciclo, utilizando [CoolProp](http://www.coolprop.org/index.html) via [Pycall.jl](https://github.com/JuliaPy/PyCall.jl) para propriedades termofísicas.
"""

# ╔═╡ 32a25170-88f8-11eb-2b1a-a74304a5c40d
function solve(
		WC, 		# Potência de compresssão, (kW)
		ηC, 		# Eficiência isentrópica, (norm)
		IC,			# Fração de perda de irrev. por calor, (norm)
		Tc, 		# Temp. de condensação (K)
		Te; 		# Temp. de evaporação (K)
		FL="R134a"	# Fluido refrigerante (CoolProp name)
	)
	# Cycle States
	St1 = CP.State(FL, Dict("T" => Te, "Q" => 1)) # All T's in K
	St3 = CP.State(FL, Dict("T" => Tc, "Q" => 0))
	S2s = CP.State(FL, Dict("P" => St3.p, "S" => St1.s))
	wCs = S2s.h - St1.h	# Isentropic compressor work
	wCr = wCs / ηC		# ηC normalized
	IrC = wCr - wCs		# Irreversibility, normalized
	qCs = IC * IrC		# Compressor heat loss
	h_2 = St1.h + wCr - qCs		# Energy balance
	St2 = CP.State(FL, Dict("P" => St3.p, "H" => h_2))
	St4 = CP.State(FL, Dict("P" => St1.p, "H" => St3.h))
	# Quantities of interest
	md  = WC / wCr
	q23 = St2.h - St3.h
	q41 = St1.h - St4.h
	COP = q41 / wCr
	return (md, md * q23, md * q41, COP * 1.0e+2)
end

# ╔═╡ 9f4f1ef4-88fb-11eb-0b47-0568605b0400
begin
	A, B, C, D = solve(
		the[:WC],
		the[:ηC] / 1.0e+2,
		the[:IC] / 1.0e+2,
		the[:Tc] + 273.15,
		the[:Te] + 273.15,
		FL = "R134a"
	)
	Markdown.parse(
		@sprintf """
**(a)** A vazão mássica de refrigerante é de **%.4g kg/s**

**(b)** A taxa de rejeição de calor (no condensador) é de **%.4g kW**

**(c)** A capacidade de refrigeração é de **%.4g ton** (= %.4g kW)

**(d)** O COP do refrigerador é de **%.4g%%**
	""" A B C/3.517 C D
	)
end

# ╔═╡ 96c9b986-717e-11eb-21d0-5d3bdcdaf318
md"""
## Bibliotecas e Demais Recursos
"""

# ╔═╡ 0a3b27a8-71fa-11eb-32c4-517738939197
md"""
### Bibliotecas
"""

# ╔═╡ Cell order:
# ╟─570e1fe8-7206-11eb-29d3-e1b68516ba96
# ╟─056da550-71fc-11eb-3940-5d1996cf5ec2
# ╠═6dc92e96-7148-11eb-1cc3-cf2d65e8985b
# ╟─72413c5a-88f4-11eb-08d2-813542bed0f4
# ╟─7b557108-88f4-11eb-386c-5de9519fa60a
# ╟─5a2b3bd6-714b-11eb-0208-5f1b44e7cb4c
# ╟─59f6ad1c-714b-11eb-1b85-0542622b8aba
# ╠═32a25170-88f8-11eb-2b1a-a74304a5c40d
# ╠═9f4f1ef4-88fb-11eb-0b47-0568605b0400
# ╟─96c9b986-717e-11eb-21d0-5d3bdcdaf318
# ╟─0a3b27a8-71fa-11eb-32c4-517738939197
# ╠═44780316-7149-11eb-2c22-91b75023501a
