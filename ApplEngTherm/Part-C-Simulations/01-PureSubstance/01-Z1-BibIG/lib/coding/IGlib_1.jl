### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 410c4a3a-fed1-11ea-1686-658ce41086e8
using PlutoUI, Formatting, DataFrames, BrowseTables

# ╔═╡ af562ff8-01f2-11eb-2a47-21cd32b12b14
using Roots, ForwardDiff

# ╔═╡ e6313090-f7c0-11ea-0f25-5128ff9de54b
md"# Extensão da Biblioteca de Gás Ideal"

# ╔═╡ e18c6af8-fec5-11ea-0e6b-b981e5eb3c85
module IGas
	include("IGlib_0.jl")
end

# ╔═╡ 163b8bc4-fecd-11ea-2ce6-89661221500b
md"## Funcionalidade – Funções inversas

Métodos numéricos para 𝐓(u), 𝐓(h), 𝐓(pr), etc."

# ╔═╡ 33fb541e-fecd-11ea-3160-83f06e069191
md"### Definição de Tipos

Como todas as funções inversas acima – 𝐓(u), 𝐓(h), etc. – possuem o mesmo *nome*, a diferenciação entre elas se dará via **`Multiple Dispatch`**, e assim, cada função `𝐓` será especializada com base nos **tipos** de seus **argumentos**.

O objetivo de saber se o argumento é uma energia interna ou entalpia, etc., é para que se saiba (i) sua forma funcional **e** (ii) a forma funcional de sua derivada, a fim de ajustar o método numérico.

Para tanto, é necessário a criação de novos **tipos**, que **rotulem** seus valores como \"energia interna\", \"entalpia\", etc.:
"

# ╔═╡ 4305c62e-fecd-11ea-0860-9b5c08589ef1
# A Thermodynamic abstract type to hook all concrete property value types under it
abstract type THERM end

# ╔═╡ 42ed0c4c-fecd-11ea-0ba8-1f5896ef05b1
begin
	# A type to LABEL values as internal energy ones:
	struct uType <: THERM
		val
	end
	# Functor to extract the stored value `val`...
	# ... thus avoiding further implementing the type:
	(_u::uType)() = _u.val
end

# ╔═╡ 42c107f0-fecd-11ea-13ea-13f9c55afd8e
begin
	struct hType <: THERM; val; end
	(_h::hType)() = _h.val
end

# ╔═╡ e64d8a8c-0405-11eb-2921-ebe084e91de3
begin
	struct prType <: THERM; val; end
	(_p::prType)() = _p.val
end

# ╔═╡ 1991bdbe-0406-11eb-04e5-9b85aabdcc0f
begin
	struct vrType <: THERM; val; end
	(_v::vrType)() = _v.val
end

# ╔═╡ 42a999c6-fecd-11ea-2349-c32da71d098f
md"▷ Ilustração do conceito:"

# ╔═╡ 5fcee0b0-fecd-11ea-1bf0-6b338cffd03b
begin
	# First METHOD definition for the function "example":
	function example(x::uType, molr=IGas.MOLR)
		molr ?
			"ū = $(x()) kJ/kmol" :
			"u = $(x()) kJ/kg"
	end
	# Second METHOD definition for the function "example":
	function example(x::hType, molr=IGas.MOLR)
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

# ╔═╡ 428dda38-fecd-11ea-27cd-8df85d64aa87
md"### Implementação"

# ╔═╡ 7df3c0e0-fec7-11ea-135d-1d76890ccf84
begin

	#----------------------------------------------------------------------#
	#                             T(u) inverse                             #
	#----------------------------------------------------------------------#
	# "𝐓" can be typed by \bfT<tab>
	function IGas.𝐓(
			gas::IGas.IG, uVal::uType, molr=true;
			maxIt::Integer=0, epsTol::Integer=4
		)
		# Auxiliary function of whether to break due to iterations
		breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 128 : false
		# Set functions 𝑓(x) and 𝑔(x) ≡ d𝑓/dx
		𝑓 = x -> IGas.𝐮(gas, molr, T=x)
		𝑔 = x -> IGas.cv(gas, molr, T=x)
		thef, symb = (uVal)(), "u"
		ε = eps(thef)
		# Get f bounds and check
		TMin, TMax = IGas.Tmin(gas), IGas.Tmax(gas)
		fMin, fMax = 𝑓(TMin), 𝑓(TMax)
		if !(fMin <= thef <= fMax)
			throw(DomainError(thef, "out of bounds $(fMin) ⩽ $(symb) ⩽ $(fMax)."))
		end
		# Linear initial estimate and initializations
		r = (thef - fMin) / (fMax - fMin)
		T = [ TMin + r * (TMax - TMin) ] # Iterations are length(T)-1
		f = [ 𝑓(T[end]) ]
		why = :because
		# Main loop
		while true
			append!(T, T[end] + (thef - f[end]) / 𝑔(T[end]))
			append!(f, 𝑓(T[end]))
			if breakIt(length(T)-1)
				why = :it; break
			elseif abs(f[end] - thef) <= epsTol * ε
				why = :Δu; break
			end
		end
		return (
			T[end], :why => why, :it => length(T)-1,
			:Δf => abs(f[end] - uVal()),
			:Ts => T, :fs => f
		)
	end

	#----------------------------------------------------------------------#
	#                             T(h) inverse                             #
	#----------------------------------------------------------------------#
	# "𝐓" can be typed by \bfT<tab>
	function IGas.𝐓(
			gas::IGas.IG, hVal::hType, molr=true;
			maxIt::Integer=0, epsTol::Integer=4
		)
		# Auxiliary function of whether to break due to iterations
		breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 128 : false
		# Set functions 𝑓(x) and 𝑔(x) ≡ d𝑓/dx
		𝑓 = x -> IGas.𝐡(gas, molr, T=x)
		𝑔 = x -> IGas.cp(gas, molr, T=x)
		# Get u bounds as y and check
		TMin, TMax = IGas.Tmin(gas), IGas.Tmax(gas)
		hMin, hMax = 𝑓(TMin), 𝑓(TMax)
		if !(hMin <= (hVal)() <= hMax)
			throw(DomainError(hVal(), "out of bounds $(hMin) ⩽ h ⩽ $(hMax)."))
		end
		# Linear initial estimate and initializations
		r = (hVal() - hMin) / (hMax - hMin)
		T = [ TMin + r * (TMax - TMin) ] # Iterations are length(T)-1
		h = [ 𝑓(T[end]) ]
		why = :because
		# Main loop
		while true
			append!(T, T[end] + (hVal() - h[end]) / 𝑔(T[end]))
			append!(h, 𝑓(T[end]))
			if breakIt(length(T)-1)
				why = :it; break
			elseif abs(h[end] - hVal()) <= eps(hVal()) * epsTol
				why = :Δh; break
			end
		end
		return (
			T[end], :why => why, :it => length(T)-1,
			:Δh => abs(h[end] - hVal()),
			:Ts => T, :hs => h
		)
	end

	#----------------------------------------------------------------------#
	#                            T(pr) inverse                             #
	#----------------------------------------------------------------------#
	# "𝐓" can be typed by \bfT<tab>
	function IGas.𝐓(
			gas::IGas.IG, pVal::prType, molr=true;
			maxIt::Integer=0, epsTol::Integer=4
		)
		# Auxiliary function of whether to break due to iterations
		breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 128 : false
		# Set functions 𝑓(x) and 𝑔(x) ≡ d𝑓/dx
		𝑓 = x -> IGas.Pr(gas, T=x)
		𝑔 = x -> ForwardDiff.derivative(𝑓,float(x))
		# Get u bounds as y and check
		TMin, TMax = IGas.Tmin(gas), IGas.Tmax(gas)
		pMin, pMax = 𝑓(TMin), 𝑓(TMax)
		if !(pMin <= (pVal)() <= pMax)
			throw(DomainError(pVal(), "out of bounds $(pMin) ⩽ pr ⩽ $(pMax)."))
		end
		# Linear initial estimate and initializations
		r = (pVal() - pMin) / (pMax - pMin)
		T = [ TMin + r * (TMax - TMin) ] # Iterations are length(T)-1
		p = [ 𝑓(T[end]) ]
		why = :because
		# Main loop
		while true
			append!(T, T[end] + (pVal() - p[end]) / 𝑔(T[end]))
			append!(p, 𝑓(T[end]))
			if breakIt(length(T)-1)
				why = :it; break
			elseif abs(p[end] - pVal()) <= eps(pVal()) * epsTol
				why = :Δpr; break
			end
		end
		return (
			T[end], :why => why, :it => length(T)-1,
			:Δpr => abs(p[end] - pVal()),
			:Ts => T, :prs => p
		)
	end

end

# ╔═╡ 1c4805f6-fed2-11ea-07cf-477715998303
IGas.𝐓

# ╔═╡ 675de6bc-fec8-11ea-1b59-e585e8cba51a
Tu = IGas.𝐓(
	IGas.stdGas,
	uType(
		IGas.𝐮(
			IGas.stdGas,
			false,
			T=300.0
		)
	),
	false
)

# ╔═╡ 9deb79b4-fed0-11ea-0457-edc21cedbb88
collect(sprintf1("%.20f", i) for i in Tu[5].second)

# ╔═╡ b49b8540-fed1-11ea-17d7-49ff1deb2898
Th = IGas.𝐓(
	IGas.stdGas,
	hType(
		IGas.𝐡(
			IGas.stdGas,
			false,
			T=BigFloat(300.0)
		)
	),
	false
)

# ╔═╡ 7065617c-fed2-11ea-3b30-4d4b5af934e7
collect(sprintf1("%.78f", i) for i in Th[5].second)

# ╔═╡ 81979e9c-0408-11eb-3fb5-2ddf52656a27
Tp = IGas.𝐓(
	IGas.stdGas,
	prType(
		IGas.Pr(
			IGas.stdGas,
			T=300.0
		)
	),
	false
)

# ╔═╡ c4caedde-0408-11eb-042c-cf16b7a36d80
collect(sprintf1("%.78f", i) for i in Tp[5].second)

# ╔═╡ Cell order:
# ╟─e6313090-f7c0-11ea-0f25-5128ff9de54b
# ╠═410c4a3a-fed1-11ea-1686-658ce41086e8
# ╠═af562ff8-01f2-11eb-2a47-21cd32b12b14
# ╠═e18c6af8-fec5-11ea-0e6b-b981e5eb3c85
# ╟─163b8bc4-fecd-11ea-2ce6-89661221500b
# ╟─33fb541e-fecd-11ea-3160-83f06e069191
# ╠═4305c62e-fecd-11ea-0860-9b5c08589ef1
# ╠═42ed0c4c-fecd-11ea-0ba8-1f5896ef05b1
# ╠═42c107f0-fecd-11ea-13ea-13f9c55afd8e
# ╠═e64d8a8c-0405-11eb-2921-ebe084e91de3
# ╠═1991bdbe-0406-11eb-04e5-9b85aabdcc0f
# ╟─42a999c6-fecd-11ea-2349-c32da71d098f
# ╠═5fcee0b0-fecd-11ea-1bf0-6b338cffd03b
# ╟─428dda38-fecd-11ea-27cd-8df85d64aa87
# ╠═7df3c0e0-fec7-11ea-135d-1d76890ccf84
# ╠═1c4805f6-fed2-11ea-07cf-477715998303
# ╠═675de6bc-fec8-11ea-1b59-e585e8cba51a
# ╠═9deb79b4-fed0-11ea-0457-edc21cedbb88
# ╠═b49b8540-fed1-11ea-17d7-49ff1deb2898
# ╠═7065617c-fed2-11ea-3b30-4d4b5af934e7
# ╠═81979e9c-0408-11eb-3fb5-2ddf52656a27
# ╠═c4caedde-0408-11eb-042c-cf16b7a36d80
