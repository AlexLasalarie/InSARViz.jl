function wrap!(
    M::Matrix{Float32},
    low::Float32,
    hgh::Float32
)
    for (k, val) in enumerate(M)
        new_val = low + mod(val - low, hgh - low)
        M[k] = new_val
    end
    return M
end
