#==============================================================================#
#                                   IGlib.jl                                   #
#==============================================================================#

module IGlib


#------------------------------------------------------------------------------#
#                                   Imports                                    #
#------------------------------------------------------------------------------#

using CSV
using Roots, ForwardDiff


#------------------------------------------------------------------------------#
#                                  Constants                                   #
#------------------------------------------------------------------------------#

# Whether the molar base is the default one
const MOLR = false;

# Universal gas constant, with an optional precision argument
R̄(𝕡=Float64) = 𝕡(8.314472); # ± 0.000015 # kJ/kmol⋅K

# Standard Tref - for the internal energy
Tref(𝕡=Float64) = 𝕡(298.15); # K

# Standard Pref - for the entropy
Pref(𝕡=Float64) = 𝕡(100.00); # kPa

export R̄


#------------------------------------------------------------------------------#
#                                   IG Type                                    #
#------------------------------------------------------------------------------#

# IG (Ideal Gas) structure: values for each gas instance
struct IG
    MW                  # Molecular "Weight", kg/kmol
    CP::NTuple{4}       # Exactly 4 c̄p(T) coefficients
    Tmin                # T_min, K
    Tmax                # T_max, K
    sref                # s̄°ref, kJ/kmol·K
end;

export IG


#------------------------------------------------------------------------------#
#                                  Artifacts                                   #
#------------------------------------------------------------------------------#

gasRaw = CSV.File("IGTable.csv", normalizenames=true)

# Transforms a row (from the CSV file) into an IG instance
function rowToIG(row)
	IG( row.MW, (row.cp_a, row.cp_b, row.cp_c, row.cp_d),
		row.Tmin, row.Tmax, row.sref)
end;

gasLib = Dict(Symbol(r.Formula) => rowToIG(r) for r in gasRaw)

export gasLib


#------------------------------------------------------------------------------#
#                               Basic Functions                                #
#------------------------------------------------------------------------------#

function inbounds(gas::IG, T)
	𝕡 = typeof(AbstractFloat(T))
	minT, maxT = map(𝕡, (gas.Tmin, gas.Tmax))
	if !(minT <= T <= maxT)
		throw(DomainError(T, "out of bounds $(minT) ⩽ T ⩽ $(maxT)."))
	end
	true
end;

# "𝐑" can be typed by \bfR<tab>
𝐑(gas::IG, molr=MOLR, 𝕡=Float64) = molr ? R̄(𝕡) : R̄(𝕡) / 𝕡(gas.MW)

# "𝐌" can be typed by \bfM<tab>
𝐌(gas::IG, 𝕡=Float64) = 𝕡(gas.MW)

Tmin(gas::IG, 𝕡=Float64) = 𝕡(gas.Tmin)

Tmax(gas::IG, 𝕡=Float64) = 𝕡(gas.Tmax)

sref(gas::IG, 𝕡=Float64) = 𝕡(gas.sref)

# Auxiliary function of promoted types (float types relate to precision bits)!
prTy(A...) = promote_type(map(typeof, AbstractFloat.(A))...)

export 𝐑
export 𝐌
export Tmin, Tmax, sref


#------------------------------------------------------------------------------#
#                             P - T - v  Functions                             #
#------------------------------------------------------------------------------#

# "𝐏" can be typed by \bfP<tab>
𝐏(gas::IG, molr=true; T, v) = begin
	𝕡 = prTy(T, v)
	𝐑(gas, molr, 𝕡) * T / v
end

# "𝐓" can be typed by \bfT<tab>
𝐓(gas::IG, molr=true; P, v) = begin
	𝕡 = prTy(P, v)
	P * v / 𝐑(gas, molr, 𝕡)
end

# "𝐯" can be typed by \bfv<tab>
𝐯(gas::IG, molr=true; P, T) = begin
	𝕡 = prTy(P, T)
	𝐑(gas, molr, 𝕡) * T / P
end

export 𝐏
export 𝐓
export 𝐯


#------------------------------------------------------------------------------#
#                              Caloric Functions                               #
#------------------------------------------------------------------------------#

# If functions accound for integration factor, then only :cp, :cv are needed here
function coef(gas::IG, kind::Symbol = :cp, molr=MOLR, 𝕡=Float64)
	if kind == :cp 		# No coef. transformation
		ret = hcat(𝕡.(gas.CP)...)
	elseif kind == :cv 	# Translates first coef.
		ret = hcat(𝕡(gas.CP[1]) - R̄(𝕡), 𝕡.(gas.CP[2:end])...)
	end
	molr ? ret : ret ./ 𝐌(gas, 𝕡)
end;

const propF = Dict(
	:c => (x->1     , x->x    , x->x^2  , x->x^3  ),	# Tuple makes it faster
	:h => (x->x     , x->x^2/2, x->x^3/3, x->x^4/4),	# Tuple makes it faster
	:s => (x->log(x), x->x    , x->x^2/2, x->x^3/3),	# Tuple makes it faster
);

# Generic f(T) function by Symbol key
function apply(p::Symbol, T, rel=false)
	𝕡 = typeof(T)
	rel ?
		apply(p, T, false) - apply(p, Tref(𝕡), false) :
		vcat((f(T) for f in propF[p])...)
end;

cp(gas::IG, molr=MOLR; T) =	begin
	𝕡 = typeof(T)
	inbounds(gas, T) ?
		(coef(gas, :cp, molr, 𝕡) * apply(:c, T))[1] :
		zero(𝕡)
end

cv(gas::IG, molr=MOLR; T) =	begin
	𝕡 = typeof(T)
	inbounds(gas, T) ?
		(coef(gas, :cv, molr, 𝕡) * apply(:c, T))[1] :
		zero(𝕡)
end

# "γ" can be typed by \gamma<tab>
γ(gas::IG; T) = cp(gas, true, T=T) / cv(gas, true, T=T)

# "𝐮" can be typed by \bfu<tab>
𝐮(gas::IG, molr=MOLR; T) =	begin
	𝕡 = typeof(T)
	inbounds(gas, T) ?
		(coef(gas, :cv, molr, 𝕡) * apply(:h, T, true))[1] :
		zero(𝕡)
end

# "𝐡" can be typed by \bfh<tab>
𝐡(gas::IG, molr=MOLR; T) = begin
	𝕡 = typeof(T)
	inbounds(gas, T) ?
		(coef(gas, :cp, molr, 𝕡) * apply(:h, T, true))[1] +
			𝐑(gas, molr, 𝕡) * Tref(𝕡) :
		zero(𝕡)
end

# "°" can be typed by \degree<tab>
# "Partial" ideal gas entropy
s°(gas::IG, molr=MOLR; T) =	begin
	𝕡 = typeof(T)
	inbounds(gas, T) ?
		(coef(gas, :cp, molr, 𝕡) * apply(:s, T, true))[1] + (
			molr ? sref(gas, 𝕡) : sref(gas, 𝕡) / 𝐌(gas, 𝕡)
		) :
		zero(𝕡)
end

export cp, cv, γ
export 𝐮
export 𝐡
export s°


#------------------------------------------------------------------------------#
#                         Isentropic Process Functions                         #
#------------------------------------------------------------------------------#

Pr(gas::IG; T) = begin
	𝕡 = typeof(T)
	exp(s°(gas, true, T=T) / R̄(𝕡)) / exp(sref(gas, 𝕡) / R̄(𝕡))
end

vr(gas::IG; T) = T / Pr(gas, T=T)

# "𝐬" can be typed by \bfs<tab>
𝐬(gas::IG, molr=MOLR; T, P) = begin
	𝕡 = prTy(P, T)
	inbounds(gas, T) ?
		s°(gas, molr, T=T) - 𝐑(gas, molr, 𝕡) * log(P / Pref(𝕡)) :
		zero(𝕡)
end

export Pr, vr
export 𝐬


#------------------------------------------------------------------------------#
#                      Mini Property Labeling Type System                      #
#------------------------------------------------------------------------------#

# A Thermodynamic abstract type to hook all concrete property value types under it
abstract type THERM end

struct uType <: THERM; val; end
(_u::uType)() = _u.val

struct hType <: THERM; val; end
(_h::hType)() = _h.val

struct prType <: THERM; val; end
(_p::prType)() = _p.val

struct vrType <: THERM; val; end
(_v::vrType)() = _v.val

export THERM
export uType, hType, prType, vrType


#----------------------------------------------------------------------#
#                             T(u) inverse                             #
#----------------------------------------------------------------------#

# "𝐓" can be typed by \bfT<tab>
function 𝐓(
		gas::IG, uVal::uType, molr=true;
		maxIt::Integer=0, epsTol::Integer=4
	)
	# Auxiliary function of whether to break due to iterations
	breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 128 : false
	# Set functions 𝑓(x) and 𝑔(x) ≡ d𝑓/dx
	𝑓 = x -> 𝐮(gas, molr, T=x)
	𝑔 = x -> cv(gas, molr, T=x)
	thef, symb = (uVal)(), "u"
	ε, 𝕡 = eps(thef), typeof(thef)
	# Get f bounds and check
	TMin, TMax = Tmin(gas, 𝕡), Tmax(gas, 𝕡)
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
			why = :Δf; break
		end
	end
	return Dict(
		:sol => T[end],
		:why => why,
		:it  => length(T)-1,
		:Δf  => f .- thef,
		:Ts  => T,
		:fs  => f
	)
end


#----------------------------------------------------------------------#
#                             T(h) inverse                             #
#----------------------------------------------------------------------#

# "𝐓" can be typed by \bfT<tab>
function 𝐓(
		gas::IG, hVal::hType, molr=true;
		maxIt::Integer=0, epsTol::Integer=4
	)
	# Auxiliary function of whether to break due to iterations
	breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 128 : false
	# Set functions 𝑓(x) and 𝑔(x) ≡ d𝑓/dx
	𝑓 = x -> 𝐡(gas, molr, T=x)
	𝑔 = x -> cp(gas, molr, T=x)
	thef, symb = (hVal)(), "h"
	ε, 𝕡 = eps(thef), typeof(thef)
	# Get f bounds and check
	TMin, TMax = Tmin(gas, 𝕡), Tmax(gas, 𝕡)
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
			why = :Δf; break
		end
	end
	return Dict(
		:sol => T[end],
		:why => why,
		:it  => length(T)-1,
		:Δf  => f .- thef,
		:Ts  => T,
		:fs  => f
	)
end


#----------------------------------------------------------------------#
#                            T(pr) inverse                             #
#----------------------------------------------------------------------#

# "𝐓" can be typed by \bfT<tab>
function 𝐓(
		gas::IG, pVal::prType;
		maxIt::Integer=0, epsTol::Integer=4
	)
	# Auxiliary function of whether to break due to iterations
	breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 128 : false
	# Set functions 𝑓(x) and 𝑔(x) ≡ d𝑓/dx
	𝑓 = x -> Pr(gas, T=x)
	𝑔 = x -> ForwardDiff.derivative(𝑓,float(x))
	thef, symb = (pVal)(), "Pr"
	ε, 𝕡 = eps(thef), typeof(thef)
	# Get f bounds and check
	TMin, TMax = Tmin(gas, 𝕡), Tmax(gas, 𝕡)
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
			why = :Δf; break
		end
	end
	return Dict(
		:sol => T[end],
		:why => why,
		:it  => length(T)-1,
		:Δf  => f .- thef,
		:Ts  => T,
		:fs  => f
	)
end


#----------------------------------------------------------------------#
#                            T(vr) inverse                             #
#----------------------------------------------------------------------#

# "𝐓" can be typed by \bfT<tab>
function 𝐓(
		gas::IG, vVal::vrType;
		maxIt::Integer=0, epsTol::Integer=4
	)
	# Auxiliary function of whether to break due to iterations
	breakIt(i) = maxIt > 0 ? i >= maxIt || i >= 128 : false
	# Set 𝑓(x) function
	thef, symb = (vVal)(), "vr"
	𝑓 = x -> vr(gas, T=x) - thef
	ε, 𝕡 = eps(thef), typeof(thef)
	# Get f bounds and check
	TMin, TMax = Tmin(gas, 𝕡), Tmax(gas, 𝕡)
	fMin, fMax = 𝑓(TMax), 𝑓(TMin)
	if !(fMin <= zero(𝕡) <= fMax)
		throw(
			DomainError(
				thef,
				"out of bounds $(fMin+thef) ⩽ $(symb) ⩽ $(fMax+thef)."
			)
		)
	end
	# Bisection method initializations
	TB = [ TMin, TMax ] # T bounds
	FB = map(𝑓, TB)	 # 𝑓 bounds
	T = 𝕡[ ] # Iterations are length(T)
	f = 𝕡[ ]
	𝑠 = map(signbit, FB)
	why = :unbracketed
	while !reduce(==, 𝑠)
		# Main loop
		append!(T, reduce(+, TB) / 2)
		append!(f, 𝑓(T[end]))
		sMid = signbit(f[end])
		if sMid == 𝑠[1]
			TB[1], FB[1] = T[end], f[end]
		else
			TB[2], FB[2] = T[end], f[end]
		end
		if breakIt(length(T))
			why = :it; break
		elseif abs(f[end]) <= epsTol * ε
			why = :Δf; break
		end
	end
	return Dict(
		:sol => T[end],
		:why => why,
		:it  => length(T),
		:Δf  => f,
		:Ts  => T,
		:fs  => f .+ thef,
		:TB  => TB,
		:FB  => FB
	)
end

end # module
