### A Pluto.jl notebook ###
# v0.11.12

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

# ╔═╡ b88b4f04-f851-11ea-32f0-45dc4ce93e42
using PlutoUI

# ╔═╡ 70cd7f1a-f870-11ea-1b68-3b778df6ac61
using Formatting

# ╔═╡ 3b936e7e-f87b-11ea-2561-77123eaac9d8
using DataFrames

# ╔═╡ ee77c2c0-f889-11ea-2217-c7f489b706f2
using BrowseTables

# ╔═╡ 934ae304-f7ce-11ea-2b06-9b0f48cd9c22
using CSV

# ╔═╡ e6313090-f7c0-11ea-0f25-5128ff9de54b
md"# Biblioteca Simplificada de Gás Ideal

Biblioteca básica de gás ideal sob hipóteses:

- Substâncias puras;
- Função cp(T) polinomial cúbica;
- Função cp(T) válida para Tmin ⩽ T ⩽ Tmax;
- sref = s°(Tref) conhecida.
"

# ╔═╡ 3cf7ab10-f7c2-11ea-0386-97c6d1f5ffc5
md"## Setup Mínimo"

# ╔═╡ 3d7d05cc-f7d5-11ea-0419-77d8ee09161c
# Whether the molar base is the default one
const MOLR = true;

# ╔═╡ 53ea6024-f7c2-11ea-2226-f9d22949c8b7
# Universal gas constant
R̄() = 8.314472; # ± 0.000015 # kJ/kmol⋅K

# ╔═╡ 815a5db4-f7c2-11ea-1747-e3f2eccdf1b2
# Standard Tref - for the internal energy
Tref() = 298.15; # K

# ╔═╡ f26879e2-f884-11ea-0223-158b8af130b9
# Standard Pref - for the entropy
Pref() = 100.00; # kPa

# ╔═╡ 8125f198-f7c2-11ea-14e4-7f873ab2c3f4
# IG (Ideal Gas) structure: values for each gas instance
struct IG
    MW                  # Molecular "Weight", kg/kmol
    CP::NTuple{4}       # Exactly 4 c̄p(T) coefficients
    Tmin                # T_min, K
    Tmax                # T_max, K
    sref                # s̄°ref, kJ/kmol·K
end;

# ╔═╡ e66a728a-f7cd-11ea-1fe6-07c915fa1c9d
md"## Biblioteca Externa

Valores tabelados em Çengel, Y. A., Termodinâmica 7a Ed. ISBN 978-85-8055-200-3 (Tabelas A-1, A-2 e A-26), foram transportados para uma planilha (OpenOffice Spreadsheet) e exportados no formato CSV [Comma Separated Values], os quais podem ser lidos em Julia:
"

# ╔═╡ c4d73944-fd42-11ea-3245-6d150a01e7d9
begin
	iURL = "https://raw.githubusercontent.com/CNThermSci/ApplThermSci/master/ApplEngTherm/Part-C-Simulations/01-PureSubstance/01-Z1-BibIG/lib/coding/IGTable.png"
	Resource(iURL)
end

# ╔═╡ 034e8264-f7cf-11ea-2a5b-b13e84ce9026
gasRaw = CSV.File("IGTable.csv", normalizenames=true)

# ╔═╡ ad44f412-f7d2-11ea-0524-6f802013e302
# Transforms a row (from the CSV file) into an IG instance
function rowToIG(row)
	IG( row.MW, (row.cp_a, row.cp_b, row.cp_c, row.cp_d),
		row.Tmin, row.Tmax, row.sref)
end;

# ╔═╡ 21eb877c-f7d1-11ea-241a-5b5b9166d851
gasLib = Dict(Symbol(r.Formula) => rowToIG(r) for r in gasRaw)

# ╔═╡ 75bea142-f853-11ea-3a14-0b6e1ba4e188
md"## Gás Padrão

Escolha do gás padrão para testes, abaixo:"

# ╔═╡ cf58a7a8-f852-11ea-26be-7353cce3b2a2
@bind gas_choice Select([row.Formula => row.Name for row in gasRaw])

# ╔═╡ dfd9fc12-f7d5-11ea-3215-8389fe38230f
# Standard test gas
stdGas = gasLib[Symbol(gas_choice)]

# ╔═╡ 04402ca4-f7cf-11ea-02e7-2d95f990f682
md"## Funcionalidade – Verificações"

# ╔═╡ 438d85f2-f7d7-11ea-325c-273ebfc69412
md"▷ Testes:"

# ╔═╡ 5f456858-f851-11ea-2432-f5455ae9eb87
@bind bounds_test_T Slider(0:50:2400, default=0, show_value=true)

# ╔═╡ 01857e50-f7d5-11ea-0bb9-2b276266ad09
md"## Funcionalidade – Constantes"

# ╔═╡ 180ea502-f7d5-11ea-1e16-8ba66b4f6201
# "𝐑" can be typed by \bfR<tab>
𝐑(gas::IG, molr=MOLR) = molr ? R̄() : R̄() / gas.MW

# ╔═╡ 1d3d41fc-f7d6-11ea-205d-617f44dc1b64
# "𝐌" can be typed by \bfM<tab>
𝐌(gas::IG) = gas.MW

# ╔═╡ 41699000-f7d6-11ea-122a-0351461ef63c
Tmin(gas::IG) = gas.Tmin

# ╔═╡ 41475ace-f7d6-11ea-0bcf-6151365fc893
Tmax(gas::IG) = gas.Tmax

# ╔═╡ 1c5b8254-f7d7-11ea-3446-39744648cf35
function inbounds(gas::IG, T)
	if !(gas.Tmin <= T <= gas.Tmax)
		throw(DomainError(T, "out of bounds $(Tmin(gas)) ⩽ T ⩽ $(Tmax(gas))."))
	end
	true
end;

# ╔═╡ def71222-f851-11ea-23cd-3155795ae67e
begin
	flag = try inbounds(stdGas,  bounds_test_T); true; catch; false; end
	flag ?
		md"✔ A temperatura de $(bounds_test_T) K está  DENTRO  dos limites para o $(gas_choice)!" :
		md"✘ A temperatura de $(bounds_test_T) K está **FORA** dos limites para o $(gas_choice)!"
end

# ╔═╡ 412680da-f7d6-11ea-288f-c193dc4a28fd
sref(gas::IG) = gas.sref

# ╔═╡ 62876930-f7d6-11ea-1281-eb68bffdc58a
md"▷ Testes:"

# ╔═╡ e49f7636-f86c-11ea-2a2e-7751213c86e3
#begin
#	ed, sd = 5, 4 # (extra, significant)-digits
#	ff = generate_formatter("%$(sd+ed).$(sd)g")
#	local str  = "| Gás | R, kJ/kg·K | M, kg/kmol | s°ref, kJ/kmol·K |\n"
#	str *= "| :---: | :---: | :---: | :---: |\n" # This aligning stopped working...
#	for row in gasRaw
#		tmp = rowToIG(row)
#		str *= "| $(row.Formula) | $(ff(𝐑(tmp, false))) "
#		str *= "| $(ff(𝐌(tmp))) | $(ff(sref(tmp))) |\n"
#	end
#	Markdown.parse(str)
#end

begin
	ed, sd = 5, 4 # (extra, significant)-digits
	ff = generate_formatter("%$(sd+ed).$(sd)f")
	HTMLTable(DataFrame(
		:gas => [ rw.Formula for rw in gasRaw ],
		:R  =>  [ (𝑡=rowToIG(rw); sprintf1("%07.5f", 𝐑(𝑡, false))) for rw in gasRaw ],
		:M  =>  [ (𝑡=rowToIG(rw); sprintf1("%06.3f", 𝐌(𝑡))) for rw in gasRaw ],
		:s° =>  [ (𝑡=rowToIG(rw); sprintf1("%06.2f", sref(𝑡))) for rw in gasRaw ]
	))
end

# ╔═╡ 0411c8a0-f7cf-11ea-15ec-636d951c8e49
md"## Funcionalidade – Comportamento P-T-v"

# ╔═╡ 00e60032-f7d0-11ea-3784-cd9ef42ea3a6
# "𝐏" can be typed by \bfP<tab>
𝐏(gas::IG, molr=true; T, v) = 𝐑(gas, molr) * T / v

# ╔═╡ 0190c5f8-f7d0-11ea-2f9c-f73bf010a371
# "𝐓" can be typed by \bfT<tab>
𝐓(gas::IG, molr=true; P, v) = P * v / 𝐑(gas, molr)

# ╔═╡ 83badade-f7d8-11ea-08f4-11c8d11ea347
# "𝐯" can be typed by \bfv<tab>
𝐯(gas::IG, molr=true; P, T) = 𝐑(gas, molr) * T / P

# ╔═╡ c2c23006-f7d8-11ea-3bec-e30e32d01007
md"▷ Testes:"

# ╔═╡ 6104afb4-f874-11ea-128e-27ffa012d75e
md"""
`P = ` $(@bind exP Slider(80:20:1000, default=300, show_value=true)) kPa

`T = ` $(@bind exT Slider(300:20:800, default=300, show_value=true)) K

Molar base? $(@bind exm CheckBox())
"""

# ╔═╡ b2606fd8-f872-11ea-0dff-232b927a6ea9
begin
	exv = 𝐯(stdGas, exm, P=exP, T=exT)
	if exm
		md"""
		`v =` $(ff(exv)) m³/kmol
		`; P =` $(ff(𝐏(stdGas, exm, T=exT, v=exv))) kPa
		`; T =` $(ff(𝐓(stdGas, exm, P=exP, v=exv))) K.
		"""
	else
		md"""
		`v =` $(ff(exv)) m³/kg
		`; P =` $(ff(𝐏(stdGas, exm, T=exT, v=exv))) kPa
		`; T =` $(ff(𝐓(stdGas, exm, P=exP, v=exv))) K.
		"""
	end
end

# ╔═╡ 97faf1be-f7db-11ea-3e79-7f73efeaa19e
md"## Funcionalidade – Comportamento Calórico"

# ╔═╡ 7e859194-f7dd-11ea-13ef-751ab2e55ab6
md"### Transformação de coeficientes:

Coeficientes, de $c_p(T)$ ou $c_v(T)$, são retornados como uma *matriz-linha*."

# ╔═╡ a4cc2982-f7db-11ea-1fd7-67c2e0c0b6d8
# If functions accound for integration factor, then only :cp, :cv are needed here
function coef(gas::IG, kind::Symbol = :cp, molr=MOLR)
	if kind == :cp 		# No coef. transformation
		ret = hcat(gas.CP...)
	elseif kind == :cv 	# Translates first coef.
		ret = hcat(gas.CP[1] - R̄(), gas.CP[2:end]...)
	end
	molr ? ret : ret ./ gas.MW
end;

# ╔═╡ 6e7edfd4-f7de-11ea-228d-8b71b2fc2ade
md"### Funções dos coeficientes por propriedade:

Estas são as funções para serem aplicadas à temperatura, em três casos distintos. A função `apply` abaixo, faz a aplicação das funções à temperatura, retornando uma *matriz-coluna*."

# ╔═╡ 6e63a0d4-f7de-11ea-309a-416b370ef546
const propF = Dict(
	:c => (x->1     , x->x    , x->x^2  , x->x^3  ),	# Tuple makes it faster
	:h => (x->x     , x->x^2/2, x->x^3/3, x->x^4/4),	# Tuple makes it faster
	:s => (x->log(x), x->x    , x->x^2/2, x->x^3/3),	# Tuple makes it faster
);

# ╔═╡ 2ebc2ecc-f7e0-11ea-132f-492c5e6ee323
# Generic f(T) function by Symbol key
function apply(p::Symbol, T, rel=false)
	rel ?
		apply(p, T, false) - apply(p, Tref(), false) :
		vcat((f(T) for f in propF[p])...)
end;

# ╔═╡ 2200fc52-f7e1-11ea-2ee1-458510ad0ae1
md"### Propriedades Calóricas Diretas – $c_{p,v}(T)$, $u(T)$, etc:

Estas funções selecionam as matrizes linha e coluna pertinentes, multiplicando-as, extraindo e retornando o único valor da matrix 1x1 resultante, com verificação de limites e somas de eventuais termos constantes.

As funções de uma única letra ASCII tem os nomes em letras negritas (bold-face) para não conflitarem com variáveis de nomes `u` e `h`, por exemplo. Por isso nomes como: `𝐮` e `𝐡`, por exemplo, porém não `γ`, por não ser ASCII.
"

# ╔═╡ 2e7498f0-f7e0-11ea-00f3-df5a8acaeb10
cp(gas::IG, molr=MOLR; T) =	inbounds(gas, T) ?
	(coef(gas, :cp, molr) * apply(:c, T))[1] : 0.0

# ╔═╡ 2e5c0164-f7e0-11ea-37bc-2f245b5dfd7b
cv(gas::IG, molr=MOLR; T) =	inbounds(gas, T) ?
	(coef(gas, :cv, molr) * apply(:c, T))[1] : 0.0

# ╔═╡ b03d1962-f7e4-11ea-2ae9-d153c7d10f2f
# "γ" can be typed by \gamma<tab>
γ(gas::IG; T) = cp(gas, true, T=T) / cv(gas, true, T=T)

# ╔═╡ 2e3d89aa-f7e0-11ea-3704-cbc09b19a0c8
# "𝐮" can be typed by \bfu<tab>
𝐮(gas::IG, molr=MOLR; T) =	inbounds(gas, T) ?
	(coef(gas, :cv, molr) * apply(:h, T, true))[1] : 0.0

# ╔═╡ 1530d092-f7e3-11ea-180e-09ee5c270414
# "𝐡" can be typed by \bfh<tab>
𝐡(gas::IG, molr=MOLR; T) =	inbounds(gas, T) ?
	(coef(gas, :cp, molr) * apply(:h, T, true))[1] + 𝐑(gas, molr) * Tref() : 0.0

# ╔═╡ 20cd32e0-f7e3-11ea-3d79-3b12b8bd6f35
# "°" can be typed by \degree<tab>
# "Partial" ideal gas entropy
s°(gas::IG, molr=MOLR; T) =	inbounds(gas, T) ?
	(coef(gas, :cp, molr) * apply(:s, T, true))[1] + (
		molr ? gas.sref : gas.sref / gas.MW
	) : 0.0

# ╔═╡ 91fdd86c-f7e7-11ea-0505-bb2a2d99df2a
Pr(gas::IG; T) = exp(s°(gas, true, T=T) / R̄()) / # arbitrary const
	exp(gas.sref / R̄())

# ╔═╡ 91e31608-f7e7-11ea-1295-817f8f1eff16
vr(gas::IG; T) = T / Pr(gas, T=T)

# ╔═╡ 2e53aa88-f7ec-11ea-1131-ff6f6b2a1001
# "𝐬" can be typed by \bfs<tab>
𝐬(gas::IG, molr=MOLR; T, P) = inbounds(gas, T) ?
	s°(gas, molr, T=T) - 𝐑(gas, molr) * log(P/Pref()) : 0.0

# ╔═╡ 9c488798-f7e4-11ea-3878-f32ab3a0abf8
md"▷ Testes:"

# ╔═╡ 699e5762-f7e6-11ea-1724-edc2ffb575ba
# Mass-based {T, 𝐡, Pr(T), 𝐮, vr(T), s°, cp, cv, γ} - Table for the `stdGas`:
begin
	digs = 4
	T = collect(300:100:1800)
	HTMLTable(DataFrame(
		:T  => T,
		:h  => [round(𝐡(stdGas, false, T=i), digits=digs) for i in T],
		:Pr => [round(Pr(stdGas, T=i), digits=digs) for i in T],
		:u  => [round(𝐮(stdGas, false, T=i), digits=digs) for i in T],
		:vr => [round(vr(stdGas, T=i), digits=digs) for i in T],
		:s° => [round(s°(stdGas, false, T=i), digits=digs) for i in T],
		:cp => [round(cp(stdGas, false, T=i), digits=digs) for i in T],
		:cv => [round(cv(stdGas, false, T=i), digits=digs) for i in T],
		:γ  => [round(γ(stdGas, T=i), digits=digs) for i in T]
	))
end

# ╔═╡ cffbf3de-f7eb-11ea-02ad-99e2c3da9928
md"## Funcionalidade – Funções inversas

Métodos numéricos para 𝐓(u), 𝐓(h), 𝐓(pr), etc."

# ╔═╡ 9907e294-f916-11ea-011a-53c94fda1159
md"### Definição de Tipos

Como todas as funções inversas acima – 𝐓(u), 𝐓(h), etc. – possuem o mesmo *nome*, a diferenciação entre elas se dará via **`Multiple Dispatch`**, e assim, cada função `𝐓` será especializada com base nos **tipos** de seus **argumentos**.

O objetivo de saber se o argumento é uma energia interna ou entalpia, etc., é para que se saiba (i) sua forma funcional **e** (ii) a forma funcional de sua derivada, a fim de ajustar o método numérico.

Para tanto, é necessário a criação de novos **tipos**, que **rotulem** seus valores como \"energia interna\", \"entalpia\", etc.:
"

# ╔═╡ f0602c94-f7eb-11ea-1d41-6f2bc4f40aaf
# A Thermodynamic abstract type to hook all special property values under it
abstract type THERM end

# ╔═╡ 6d0c5c68-f90e-11ea-30f5-0fb6284dabbf
begin
	# A type to LABEL values as internal energy ones:
	struct uType <: THERM
		val
	end
	# Functor to extract the stored value `val`...
	# ... thus avoiding further implementing the type:
	(u::uType)() = u.val
end

# ╔═╡ 6d36d556-f90e-11ea-23ae-4bbcf752c3c9
begin
	# A type to LABEL values as enthalpy ones:
	struct hType <: THERM
		val
	end
	# Functor to extract the stored value `val`...
	# ... thus avoiding further implementing the type:
	(h::hType)() = h.val
end

# ╔═╡ 2a602e28-f916-11ea-0425-f31cd6eb93c1
md"▷ Ilustração do conceito:"

# ╔═╡ 0251323a-f914-11ea-2685-c502e35e6fc3
begin
	# First METHOD definition for the function "example":
	function example(x::uType, molr=MOLR)
		molr ?
			"ū = $(x()) kJ/kmol" :
			"u = $(x()) kJ/kg"
	end
	# Second METHOD definition for the function "example":
	function example(x::hType, molr=MOLR)
		molr ?
			"h̄ = $(x()) kJ/kmol" :
			"h = $(x()) kJ/kg"
	end
	# Same function name "example" called: specialize based on argument(s) TYPE(s):
	vcat(
		example(uType(314.15)),			# uType argument
		example(hType(314.15), false),	# htype argument
		uType(3.14)() == hType(3.14)()	# Their _values_ are the same!
	)
end

# ╔═╡ 099c8786-f918-11ea-1fbb-e553d989d1ea
md"### Implementação"

# ╔═╡ 95e89cb0-fa20-11ea-26c7-3d1a65f19248


# ╔═╡ Cell order:
# ╟─e6313090-f7c0-11ea-0f25-5128ff9de54b
# ╠═b88b4f04-f851-11ea-32f0-45dc4ce93e42
# ╠═70cd7f1a-f870-11ea-1b68-3b778df6ac61
# ╠═3b936e7e-f87b-11ea-2561-77123eaac9d8
# ╠═ee77c2c0-f889-11ea-2217-c7f489b706f2
# ╟─3cf7ab10-f7c2-11ea-0386-97c6d1f5ffc5
# ╠═3d7d05cc-f7d5-11ea-0419-77d8ee09161c
# ╠═53ea6024-f7c2-11ea-2226-f9d22949c8b7
# ╠═815a5db4-f7c2-11ea-1747-e3f2eccdf1b2
# ╠═f26879e2-f884-11ea-0223-158b8af130b9
# ╠═8125f198-f7c2-11ea-14e4-7f873ab2c3f4
# ╟─e66a728a-f7cd-11ea-1fe6-07c915fa1c9d
# ╟─c4d73944-fd42-11ea-3245-6d150a01e7d9
# ╠═934ae304-f7ce-11ea-2b06-9b0f48cd9c22
# ╠═034e8264-f7cf-11ea-2a5b-b13e84ce9026
# ╠═ad44f412-f7d2-11ea-0524-6f802013e302
# ╠═21eb877c-f7d1-11ea-241a-5b5b9166d851
# ╟─75bea142-f853-11ea-3a14-0b6e1ba4e188
# ╠═cf58a7a8-f852-11ea-26be-7353cce3b2a2
# ╠═dfd9fc12-f7d5-11ea-3215-8389fe38230f
# ╟─04402ca4-f7cf-11ea-02e7-2d95f990f682
# ╠═1c5b8254-f7d7-11ea-3446-39744648cf35
# ╟─438d85f2-f7d7-11ea-325c-273ebfc69412
# ╟─5f456858-f851-11ea-2432-f5455ae9eb87
# ╟─def71222-f851-11ea-23cd-3155795ae67e
# ╟─01857e50-f7d5-11ea-0bb9-2b276266ad09
# ╠═180ea502-f7d5-11ea-1e16-8ba66b4f6201
# ╠═1d3d41fc-f7d6-11ea-205d-617f44dc1b64
# ╠═41699000-f7d6-11ea-122a-0351461ef63c
# ╠═41475ace-f7d6-11ea-0bcf-6151365fc893
# ╠═412680da-f7d6-11ea-288f-c193dc4a28fd
# ╟─62876930-f7d6-11ea-1281-eb68bffdc58a
# ╟─e49f7636-f86c-11ea-2a2e-7751213c86e3
# ╟─0411c8a0-f7cf-11ea-15ec-636d951c8e49
# ╠═00e60032-f7d0-11ea-3784-cd9ef42ea3a6
# ╠═0190c5f8-f7d0-11ea-2f9c-f73bf010a371
# ╠═83badade-f7d8-11ea-08f4-11c8d11ea347
# ╟─c2c23006-f7d8-11ea-3bec-e30e32d01007
# ╟─6104afb4-f874-11ea-128e-27ffa012d75e
# ╟─b2606fd8-f872-11ea-0dff-232b927a6ea9
# ╟─97faf1be-f7db-11ea-3e79-7f73efeaa19e
# ╟─7e859194-f7dd-11ea-13ef-751ab2e55ab6
# ╠═a4cc2982-f7db-11ea-1fd7-67c2e0c0b6d8
# ╟─6e7edfd4-f7de-11ea-228d-8b71b2fc2ade
# ╠═6e63a0d4-f7de-11ea-309a-416b370ef546
# ╠═2ebc2ecc-f7e0-11ea-132f-492c5e6ee323
# ╟─2200fc52-f7e1-11ea-2ee1-458510ad0ae1
# ╠═2e7498f0-f7e0-11ea-00f3-df5a8acaeb10
# ╠═2e5c0164-f7e0-11ea-37bc-2f245b5dfd7b
# ╠═b03d1962-f7e4-11ea-2ae9-d153c7d10f2f
# ╠═2e3d89aa-f7e0-11ea-3704-cbc09b19a0c8
# ╠═1530d092-f7e3-11ea-180e-09ee5c270414
# ╠═20cd32e0-f7e3-11ea-3d79-3b12b8bd6f35
# ╠═91fdd86c-f7e7-11ea-0505-bb2a2d99df2a
# ╠═91e31608-f7e7-11ea-1295-817f8f1eff16
# ╠═2e53aa88-f7ec-11ea-1131-ff6f6b2a1001
# ╟─9c488798-f7e4-11ea-3878-f32ab3a0abf8
# ╟─699e5762-f7e6-11ea-1724-edc2ffb575ba
# ╟─cffbf3de-f7eb-11ea-02ad-99e2c3da9928
# ╟─9907e294-f916-11ea-011a-53c94fda1159
# ╠═f0602c94-f7eb-11ea-1d41-6f2bc4f40aaf
# ╠═6d0c5c68-f90e-11ea-30f5-0fb6284dabbf
# ╠═6d36d556-f90e-11ea-23ae-4bbcf752c3c9
# ╟─2a602e28-f916-11ea-0425-f31cd6eb93c1
# ╠═0251323a-f914-11ea-2685-c502e35e6fc3
# ╟─099c8786-f918-11ea-1fbb-e553d989d1ea
# ╠═95e89cb0-fa20-11ea-26c7-3d1a65f19248
