!% This file contains a single module with several module-level vars
!% with one of them a derived type, which is defined in the 'base library'.

module use_a_type
    use define_a_type !% This is the module which defines the type 'atype'
    type(atype), target :: P  !% A variable with this type. NB: target attribute needed to allow access from Python
    type(atype), allocatable :: P_array(:) !% An array of derived types (not yet wrapped, but will be soon)
    real(8),allocatable :: vector(:) !% It also contains allocatable arrays

    ! For simplicity, P has a variable of each of several base types.
    ! That is, a logical, real, integer, real array (not allocatable!), and a
    ! derived type from a different module.

    !I make a mock subroutine that uses all these bits in some way to make
    !sure they all work.
    contains

    !% Here's a routine that does something
    subroutine do_stuff(factor,out)
        real(8), intent(in) :: factor
        real(8), intent(out):: out

        integer :: i

        if (allocated(vector))   deallocate(vector)
        allocate(vector(P%integ))

        ! This construct uses the real, integer and logical vars of P
        if (P%bool)then
            do i=1,P%integ
                out = factor*P%rl
                P%rl = out
            end do
        else
            do i=1,P%integ
                out = P%rl/factor
                P%rl = out
            end do
        end if

        ! This construct fills out the allocatable module vector
        do i=1,P%integ
            vector(i) = out/(i*factor)
        end do

        !This construct uses the array and derived type vars of P
        do i=1,size(P%vec)
            P%vec(i) = P%dtype%rl*i
        end do

        call use_set_vars()

    end subroutine do_stuff

    subroutine not_used(x,y)
        real(8), intent(in) :: x
        real(8), intent(out) :: y
        type(unused_type) :: T

        y = P%rl * x
        y = T%rl * y
    end subroutine

end module
