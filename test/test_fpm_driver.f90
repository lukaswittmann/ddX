program test_fpm_driver
  implicit none
  integer :: istat, i, j, level
  character(len=512) :: path, prefix, cmd

  ! Try absolute path first (repository root)
  call execute_command_line('test -x /home/wittmann/Documents/projects/software-programs/ddX/test/fpm-test.sh', exitstat=istat)
  if (istat == 0) then
    call execute_command_line('bash /home/wittmann/Documents/projects/software-programs/ddX/test/fpm-test.sh', exitstat=istat)
    if (istat /= 0) then
      stop 1
    end if
    stop 0
  end if

  do level = 0, 5
    if (level == 0) then
      prefix = './'
    else
      prefix = ''
      do j = 1, level
        prefix = prefix // '../'
      end do
    end if
    path = prefix // 'test/fpm-test.sh'
    call execute_command_line('test -x ' // trim(path), exitstat=istat)
    if (istat == 0) then
      cmd = 'bash ' // trim(path)
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
