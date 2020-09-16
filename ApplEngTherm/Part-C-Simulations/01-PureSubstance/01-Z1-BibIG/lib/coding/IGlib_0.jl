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

# ╔═╡ 934ae304-f7ce-11ea-2b06-9b0f48cd9c22
using CSV

# ╔═╡ c2f7b900-f7e8-11ea-0456-ab265d2f6616
using DataFrames

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
# Standard Tref
Tref() = 298.15; # K

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
md"## Funcionalidade da Biblioteca – Verificações"

# ╔═╡ 438d85f2-f7d7-11ea-325c-273ebfc69412
md"▷ Testes:"

# ╔═╡ 5f456858-f851-11ea-2432-f5455ae9eb87
@bind bounds_test_T Slider(0:50:2000, default=0, show_value=true)

# ╔═╡ 01857e50-f7d5-11ea-0bb9-2b276266ad09
md"## Funcionalidade da Biblioteca – Constantes"

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

# ╔═╡ 8687cd74-f7d5-11ea-0d50-47318635afde
𝐑(stdGas), 𝐑(stdGas, false), 𝐌(stdGas), Tmin(stdGas), Tmax(stdGas), sref(stdGas)

# ╔═╡ 673f8582-f7db-11ea-3ee3-11f11ca73fdb
stdGas

# ╔═╡ 0411c8a0-f7cf-11ea-15ec-636d951c8e49
md"### Comportamento P-T-v do gás

Sem verificações de limites (bounds) de temperatura."

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

# ╔═╡ cbc82ffc-f7d8-11ea-1e4b-8d3cd84c9a5f
# Interprets T: K and v: m³/kmol
𝐏(stdGas, true, T = 300, v = 1)

# ╔═╡ 868c49ea-f7d9-11ea-0b80-79139d382790
# Interprets T: K and v: m³/kg
𝐏(stdGas, false, T = 300, v = 1)

# ╔═╡ cbab9ca0-f7d8-11ea-355e-b7b61d26d393
# Interprets v: m³/kg
𝐓(stdGas, false, P = 100, v = 1)

# ╔═╡ 371daede-f7da-11ea-28fb-a113abe130df
# Returns v: m³/kg, then v in the default (molar/mass) base
𝐯(stdGas, false, P = 100, T = 298.15),
𝐯(stdGas,        P = 100, T = 298.15)

# ╔═╡ 97faf1be-f7db-11ea-3e79-7f73efeaa19e
md"### Comportamento calórico do gás

Com verificações de limites (bounds) de temperatura."

# ╔═╡ 7e859194-f7dd-11ea-13ef-751ab2e55ab6
md"#### Funções de transformação de coeficientes:"

# ╔═╡ a4cc2982-f7db-11ea-1fd7-67c2e0c0b6d8
# If functions accound for integration factor, then only :cp, :cv are needed here
function coef(gas::IG, kind::Symbol = :cp, molr=MOLR)
	if kind == :cp 		# No coef. transformation
		ret = hcat(gas.CP...)
	elseif kind == :cv 	# Translates first coeff.
		ret = hcat(gas.CP[1] - R̄(), gas.CP[2:end]...)
	end
	molr ? ret : ret ./ gas.MW
end

# ╔═╡ 5fa1aa8c-f7de-11ea-0273-91f322669afd
md"▷ Tests:"

# ╔═╡ 6eca2fde-f7de-11ea-2acb-2d38e852db17
coef(stdGas), coef(stdGas, :cv)

# ╔═╡ 78f6e73c-f7e2-11ea-1ed0-9d3c4cbc679b
coef(stdGas, :cp, false),
coef(stdGas, :cv, false)

# ╔═╡ 6e7edfd4-f7de-11ea-228d-8b71b2fc2ade
md"#### Funções dos coeficientes por propriedade:"

# ╔═╡ 6e63a0d4-f7de-11ea-309a-416b370ef546
const propF = Dict(
	:c => (x->1     , x->x    , x->x^2  , x->x^3  ),	# Tuple makes it faster
	:h => (x->x     , x->x^2/2, x->x^3/3, x->x^4/4),	# Tuple makes it faster
	:s => (x->log(x), x->x    , x->x^2/2, x->x^3/3),	# Tuple makes it faster
)

# ╔═╡ 2ebc2ecc-f7e0-11ea-132f-492c5e6ee323
# Generic f(T) function by Symbol key
function apply(p::Symbol, T, rel=false)
	rel ?
		vcat((f(T) for f in propF[p])...) - vcat((f(Tref()) for f in propF[p])...) :
		vcat((f(T) for f in propF[p])...)
end

# ╔═╡ e78b2e58-f7e0-11ea-2ec0-0d918bc66c70
md"▷ Tests:"

# ╔═╡ 2ea88b1a-f7e0-11ea-1cc6-8bd2286cebc3
apply(:c, 300.0), apply(:h, 300.0), apply(:s, 300.0)

# ╔═╡ 408cb182-f7e3-11ea-0066-7d0376cf8149
apply(:h, Tref() + 0.001, true)

# ╔═╡ 2200fc52-f7e1-11ea-2ee1-458510ad0ae1
md"#### Funções de usuário:"

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
	(coef(gas, :cp, molr) * apply(:s, T, true))[1] + 
	(molr ? gas.sref : gas.sref / gas.MW) : 0.0

# ╔═╡ 91fdd86c-f7e7-11ea-0505-bb2a2d99df2a
Pr(gas::IG; T) = exp(s°(gas, true, T=T) / 𝐑(gas, true))

# ╔═╡ 91e31608-f7e7-11ea-1295-817f8f1eff16
vr(gas::IG; T) = T / Pr(gas, T=T)

# ╔═╡ 2e53aa88-f7ec-11ea-1131-ff6f6b2a1001
# Missing entropy!
# 𝐬:𝐬(gas, T, P)

# ╔═╡ 9c488798-f7e4-11ea-3878-f32ab3a0abf8
md"▷ Tests:"

# ╔═╡ a3c3ab56-f7e4-11ea-36e1-0f3a533d634d
cp(stdGas, false, T=300), cv(stdGas, false, T=300), γ(stdGas, T=300)

# ╔═╡ a392eb56-f7e4-11ea-2fae-b32ecedb9b43
𝐮(stdGas, false, T=300), 𝐮(stdGas, false, T=Tref())

# ╔═╡ a365fd94-f7e4-11ea-1353-870d15118696
𝐡(stdGas, false, T=400), 𝐮(stdGas, false, T=400) + 𝐏(stdGas, false, T=400, v=1)

# ╔═╡ a348b826-f7e4-11ea-3c06-7fef37879c59
𝐡(stdGas, true, T=400), 𝐮(stdGas, true, T=400) + 𝐏(stdGas, true, T=400, v=1)

# ╔═╡ a32b29a6-f7e4-11ea-26e9-2fb215d25726
𝐡(stdGas, T=Tref()), 𝐑(stdGas) * Tref()

# ╔═╡ 1f678c40-f7e6-11ea-18ab-e51e52d3f3e1
𝐡(stdGas, false, T=Tref()), 𝐑(stdGas, false) * Tref()

# ╔═╡ 568caf66-f7e6-11ea-000e-e925ee086a07
s°(stdGas, T=Tref()), sref(stdGas)

# ╔═╡ 69d8e7ee-f7e6-11ea-2c9f-eb385aafc015
s°(stdGas, T=300), s°(stdGas, T=1800)

# ╔═╡ 699e5762-f7e6-11ea-1724-edc2ffb575ba
# Mass-based {T, 𝐡, Pr(T), 𝐮, vr(T), s°} - Table for the `stdGas`:
begin
	T = collect(300:100:1800)
	DataFrame(
		:T  => T,
		:h  => [𝐡(stdGas, false, T=i) for i in T],
		:Pr => [Pr(stdGas, T=i) * 1.0e-10 for i in T],
		:u  => [𝐮(stdGas, false, T=i) for i in T],
		:vr => [vr(stdGas, T=i) / 1.0e-10 for i in T],
		:s° => [s°(stdGas, false, T=i) for i in T]
	)
end

# ╔═╡ cffbf3de-f7eb-11ea-02ad-99e2c3da9928
md"### Funções inversas

Métodos numéricos para 𝐓(u), 𝐓(h), etc."

# ╔═╡ f0602c94-f7eb-11ea-1d41-6f2bc4f40aaf
# To be implemented!

# ╔═╡ Cell order:
# ╟─e6313090-f7c0-11ea-0f25-5128ff9de54b
# ╠═b88b4f04-f851-11ea-32f0-45dc4ce93e42
# ╟─3cf7ab10-f7c2-11ea-0386-97c6d1f5ffc5
# ╠═3d7d05cc-f7d5-11ea-0419-77d8ee09161c
# ╠═53ea6024-f7c2-11ea-2226-f9d22949c8b7
# ╠═815a5db4-f7c2-11ea-1747-e3f2eccdf1b2
# ╠═8125f198-f7c2-11ea-14e4-7f873ab2c3f4
# ╟─e66a728a-f7cd-11ea-1fe6-07c915fa1c9d
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
# ╠═8687cd74-f7d5-11ea-0d50-47318635afde
# ╠═673f8582-f7db-11ea-3ee3-11f11ca73fdb
# ╟─0411c8a0-f7cf-11ea-15ec-636d951c8e49
# ╠═00e60032-f7d0-11ea-3784-cd9ef42ea3a6
# ╠═0190c5f8-f7d0-11ea-2f9c-f73bf010a371
# ╠═83badade-f7d8-11ea-08f4-11c8d11ea347
# ╟─c2c23006-f7d8-11ea-3bec-e30e32d01007
# ╠═cbc82ffc-f7d8-11ea-1e4b-8d3cd84c9a5f
# ╠═868c49ea-f7d9-11ea-0b80-79139d382790
# ╠═cbab9ca0-f7d8-11ea-355e-b7b61d26d393
# ╠═371daede-f7da-11ea-28fb-a113abe130df
# ╟─97faf1be-f7db-11ea-3e79-7f73efeaa19e
# ╟─7e859194-f7dd-11ea-13ef-751ab2e55ab6
# ╠═a4cc2982-f7db-11ea-1fd7-67c2e0c0b6d8
# ╟─5fa1aa8c-f7de-11ea-0273-91f322669afd
# ╠═6eca2fde-f7de-11ea-2acb-2d38e852db17
# ╠═78f6e73c-f7e2-11ea-1ed0-9d3c4cbc679b
# ╟─6e7edfd4-f7de-11ea-228d-8b71b2fc2ade
# ╠═6e63a0d4-f7de-11ea-309a-416b370ef546
# ╠═2ebc2ecc-f7e0-11ea-132f-492c5e6ee323
# ╟─e78b2e58-f7e0-11ea-2ec0-0d918bc66c70
# ╠═2ea88b1a-f7e0-11ea-1cc6-8bd2286cebc3
# ╠═408cb182-f7e3-11ea-0066-7d0376cf8149
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
# ╠═a3c3ab56-f7e4-11ea-36e1-0f3a533d634d
# ╠═a392eb56-f7e4-11ea-2fae-b32ecedb9b43
# ╠═a365fd94-f7e4-11ea-1353-870d15118696
# ╠═a348b826-f7e4-11ea-3c06-7fef37879c59
# ╠═a32b29a6-f7e4-11ea-26e9-2fb215d25726
# ╠═1f678c40-f7e6-11ea-18ab-e51e52d3f3e1
# ╠═568caf66-f7e6-11ea-000e-e925ee086a07
# ╠═69d8e7ee-f7e6-11ea-2c9f-eb385aafc015
# ╠═c2f7b900-f7e8-11ea-0456-ab265d2f6616
# ╠═699e5762-f7e6-11ea-1724-edc2ffb575ba
# ╟─cffbf3de-f7eb-11ea-02ad-99e2c3da9928
# ╠═f0602c94-f7eb-11ea-1d41-6f2bc4f40aaf
