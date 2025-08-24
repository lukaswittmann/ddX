#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="/tmp/ddx_fpm_$$"
mkdir -p "$TMP/src" "$TMP/test"
cat > "$TMP/fpm.toml" <<'FPM'
name = "ddx"
version = "0.6.1"
license = "LGPL-3.0"
[build]
auto-executables = false
auto-tests = false
auto-examples = false
[install]
library = false
FPM

# symlink only Fortran sources
shopt -s nullglob
for f in "$REPO_ROOT"/src/*.{f90,F90,f,F}; do
  [ -f "$f" ] && ln -sf "$f" "$TMP/src/"
done

# symlink standalone tests
ln -sf "$REPO_ROOT"/tests/standalone_tests/run_test.py "$TMP/test/"
for t in "$REPO_ROOT"/tests/standalone_tests/*.{txt,ref}; do
  [ -f "$t" ] && ln -sf "$t" "$TMP/test/"
done

cd "$TMP"
# Build the Fortran library with fpm (OpenMP flags)
fpm build --flag "-fopenmp" --link-flag "-fopenmp"

# locate fpm module dir and library, then build driver linking it
MODROOT=$(ls -d build/gfortran_* | head -n1)
LIBDIR="$MODROOT/ddx"
OUT="$TMP/build/ddx_driver"
# Use system BLAS/LAPACK - change to -lopenblas if required
gfortran -fopenmp -J "$MODROOT" -I "$MODROOT" "$REPO_ROOT/src/ddx_driver.f90" -L "$LIBDIR" -lddx -lblas -llapack -lm -lgfortran -o "$OUT"

# create a small wrapper in test to run the driver
cat > "$TMP/test/ddx_driver_testing" <<'WR'
#!/usr/bin/env bash
exec "$(realpath "$OUT")" "$@"
WR
chmod +x "$TMP/test/ddx_driver_testing"

# run tests
echo "Running standalone tests in $TMP/test"
(cd "$TMP/test" && python3 run_test.py cosmo && python3 run_test.py lpb && python3 run_test.py pcm)

echo "All tests passed. Temporary workspace kept at: $TMP"
