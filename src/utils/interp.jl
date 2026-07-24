function interp(
    vec::AbstractVector{T},
    npts::Integer
) where T
    len = length(vec)
    OutType = typeof(float(zero(T)))
    vec_out = Vector{OutType}(undef, npts)
    for (k, stop) in enumerate(range(1, len, length=npts))
        i1 = clamp(floor(Int, stop), 1, len)
        i2 = clamp(ceil(Int, stop), 1, len)
        frac = stop - i1
        val1 = vec[i1]
        val2 = vec[i2]
        vec_out[k] = val1 + (val2 - val1) * frac
    end
    return vec_out
end
