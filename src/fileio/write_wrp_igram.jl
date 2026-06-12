"""
    write_wrp_igram!(raw_buffer::AbstractMatrix{Float32}, wrp::AbstractMatrix{ComplexF32}, wrp_name::String)

Write a complex valued matrix to disk using a pre-allocated buffer.
Data is stored in interleaved Real/Imaginary format (R1, I1, R2, I2...).

# Arguments
- `raw_buffer`: pre-allocated `AbstractMatrix{Float32}` of size `(2*width, length)`.
- `wrp`: `AbstractMatrix{ComplexF32}` of size `(length, width)`.
- `wrp_name`: path to the binary interferogram file.

# Returns
- `AbstractMatrix{ComplexF32}`: modified `raw_buffer`.

# Note
This function is the high-performance, in-place version of `write_wrp_igram`.
Use this version for batch processing where the buffer can be reused.
"""
function write_wrp_igram!(raw_buffer::AbstractMatrix{Float32}, wrp::AbstractMatrix{ComplexF32}, wrp_name::String)

    # Fills buffer (no allocs)
    wrp_length, wrp_width = size(wrp)
    @inbounds for i in 1:wrp_length
        for j in 1:wrp_width
            val = wrp[i, j]
            raw_buffer[2*j-1, i] = real(val)
            raw_buffer[2*j, i] = imag(val)
        end
    end

    # Writes to disk
    open(wrp_name, "w") do io
        write(io, raw_buffer)
    end

    # Exit
    return nothing
end

"""
    write_wrp_igram(wrp_name::String, wrp::AbstractMatrix{ComplexF32})

Write a wrapped interferogram to disk using standard format.
Data is stored in interleaved Real/Imaginary format (R1, I1, R2, I2...).

# Arguments
- `wrp_name`: Path to wrapped interferogram file.
- `wrp`: complex-valued interferogram to be written out.
"""
function write_wrp_igram(wrp_name::String, wrp::AbstractMatrix{ComplexF32})

    # Creates buffer
    wrp_length, wrp_width = size(wrp)
    raw_buffer = Matrix{Float32}(undef, 2 * wrp_width, wrp_length)

    # Writes to file
    write_wrp_igram!(raw_buffer, wrp, wrp_name)
end
