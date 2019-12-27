# pySTK - Python bindings for Sierra Toolkit (STK)

pySTK is a Python/Cython wrapper to provide a python interface to STK. Please
consult [documentation](https://sayerhs.github.io/pystk/index.html) for
installation and usage instructions.

## Requirements

To use a previously built pySTK library the following must be installed on your system:

- Sierra Toolkit (STK) library from [Trilinos](https://github.com/trilinos/trilinos)
- Python (`>3.5`)
- [NumPy](https://numpy.org/)

Optional dependencies

If STK was compiled using Message Passing Interface (MPI) then the library will
attempt to access the MPI libraries when loaded.

### Build/development dependencies

To build from source, or for developing pySTK the following additional packages
are necessary:

- [Cython](https://cython.org/) (`>0.25.1`)
- [scikit-build](https://github.com/scikit-build/scikit-build)

Optional dependencies

- [pytest](https://docs.pytest.org/en/latest/index.html) - for testing
- [Sphinx](https://www.sphinx-doc.org/en/master/) - for building documentation

## Other information

- License: Apache License, Version 2.0
