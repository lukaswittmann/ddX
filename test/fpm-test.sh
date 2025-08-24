#!/usr/bin/env bash
set -euo pipefail

# Wrapper to build the library, compile the driver linking it,
# and run the standalone test runner.

echo "Running fpm test wrapper"

# build project with OpenMP flags
fpm build --flag "-fopenmp" --link-flag "-fopenmp"

# locate fpm build directory and library
# locate the fpm module directory that contains the compiled .mod files
MODROOT=""
for d in build/gfortran_*; do
  if [ -f "$d/ddx.mod" ]; then
    MODROOT="$d"
    break
  fi
done
if [ -z "$MODROOT" ]; then
  echo "Error: could not find build/gfortran_* that contains ddx.mod"
  exit 1
fi
LIBDIR="$MODROOT/ddx"
OUT="$MODROOT/ddx_driver"
OUT_ABS=$(realpath "$OUT")

# compile the driver linking the library (use system BLAS/LAPACK)
gfortran -fopenmp -J "$MODROOT" -I "$MODROOT" src/ddx_driver.f90 -L "$LIBDIR" -lddx -lblas -llapack -lm -lgfortran -o "$OUT"

# create a small wrapper in the standalone tests directory so run_test.py
# can invoke it as ./ddx_driver_testing
WRAPPER="tests/standalone_tests/ddx_driver_testing"
cat > "$WRAPPER" <<WR
#!/usr/bin/env bash
exec "${OUT_ABS}" "\$@"
WR
chmod +x "$WRAPPER"

echo "Running standalone tests"
(cd tests/standalone_tests && python3 run_test.py cosmo && python3 run_test.py lpb && python3 run_test.py pcm)

echo "All standalone tests passed"
