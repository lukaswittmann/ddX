program fpm_test_runner
  implicit none
  integer :: istat
  character(len=4096) :: cmd
  cmd = 'bash test/fpm-test.sh'
  call execute_command_line(trim(cmd), exitstat=istat)
  if (istat /= 0) then
     stop 1
  end if
end program fpm_test_runner

