program test_fpm_driver
  implicit none
  integer :: istat, i
  character(len=256), dimension(6) :: paths
  character(len=512) :: cmd

  paths = (/'./test/fpm-test.sh','../test/fpm-test.sh','../../test/fpm-test.sh',&
            '../../../test/fpm-test.sh','../../../../test/fpm-test.sh','/test/fpm-test.sh'/)

  do i = 1, size(paths)
    call execute_command_line('test -x ' // trim(paths(i)), exitstat=istat)
    if (istat == 0) then
      cmd = 'bash ' // trim(paths(i))
      call execute_command_line(trim(cmd), exitstat=istat)
      if (istat /= 0) then
        stop 1
      end if
      stop 0
    end if
  end do

  ! If we reach here no wrapper found
  stop 1
end program test_fpm_driver
