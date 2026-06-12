"""
    read_wrp_igram!(raw_buffer::AbstractMatrix{ComplexF32}, wrp_buffer::AbstractMatrix{ComplexF32}, wrp_name::String)

Read a wrapped interferogram file directly into a pre-allocated buffer.

# Arguments
- `raw_buffer`: pre-allocated `Matrix{ComplexF32}` of size `(width, length)`.
- `wrp_buffer`: pre-allocated `Matrix{ComplexF32}` of size `(length, width)`.
- `wrp_name`: path to the binary interferogram file.

# Returns
- `AbstractMatrix{}`
- `AbstractMatrix{ComplexF32}`: wrapped interferogram (overwrites the buffer).

# Note
This function is the high-performance, in-place version of `read_wrp_igram`.
Use this version for batch processing where the buffer can be reused.
"""
function read_wrp_igram!(raw_buffer::AbstractMatrix{ComplexF32}, wrp_buffer::AbstractMatrix{ComplexF32}, wrp_name::String)
    open(wrp_name, "r") do io
        read!(io, raw_buffer)
    end
    transpose!(wrp_buffer, raw_buffer)
    return wrp_buffer
end


"""

    wrp = read_wrp_igram(wrp_name::String, wrp_width::Int, wrp_length::Int)

Read a wrapped interferogram of standard format.

# Arguments
- `wrp_name`: Path to wrapped interferogram file.
- `igram_width`::Int. Width of the input interferogram.
- `igram_length`::Int. Length of the input interferogram.

# Returns
- `wrp`::Array{ComplexF32}. Complex-valued (wrapped) interferogram. 
"""
function read_wrp_igram(wrp_name::String, wrp_width::Int, wrp_length::Int)
    raw_buffer = Matrix{ComplexF32}(undef, wrp_width, wrp_length)
    wrp_buffer = Matrix{ComplexF32}(undef, wrp_length, wrp_width)
    return read_wrp_igram!(raw_buffer, wrp_buffer, wrp_name)
end