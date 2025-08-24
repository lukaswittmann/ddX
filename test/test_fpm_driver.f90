program test_fpm_driver
  implicit none
  integer :: istat
  call execute_command_line('bash fpm-test.sh', exitstat=istat)
  if (istat /= 0) then
    stop 1
  end if
end program test_fpm_driver

