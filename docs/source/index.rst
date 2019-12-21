
pySTK - Python bindings for Sierra Toolkit (STK)
================================================

pySTK provides python bindings to `Sierra Toolkit
<https://trilinos.org/STK>`_ (STK). It uses the `Cython <https://cython.org>`_
bindings generator to interface with the STK C++ library. The library provides a
way to interact with `Exodus-II database
<https://prod-ng.sandia.gov/techlib-noauth/access-control.cgi/1992/922137.pdf>`_
through python for generating meshes, pre-processing and post-processing through python
scripts. The python bindings can be built on Linux and MacOS platforms for
Python3.

.. _installation:

Installation
------------

pySTK needs the following packages installed on your system to be able to
compile and build the python bindings:

**Runtime dependencies**

- `Sierra Toolkit (STK) <https://github.com/trilinos/trilinos>`_
- `Python v3.5 or higher <https://www.python.org/>`_
- `NumPy <https://numpy.org>`_

**Build time dependencies**

In addition to the runtime dependencies you will need the following packages
installed on your system to build pySTK from source

- `Cython <https://cython.org>`_
- `scikit-build <https://github.com/scikit-build/scikit-build>`_
- `CMake v3.12 or higher <https://cmake.org>`_

Optionally,  you'll also need the following for development and generating
documentation on your own machine

- `pytest <https://docs.pytest.org/en/latest>`_ for running unit tests
- `Sphinx <https://sphinx-doc.org>`_ for generating documentation

Building from source
~~~~~~~~~~~~~~~~~~~~

To build from source create a new Python environment (either *virtualenv* or
*conda env*). You can use the :file:`requirements.txt` in the base directory to
install dependencies via pip

Execute the following commands to compile and install the package

.. code-block:: bash

   # Clone the git repo
   git clone git@github.com:sayerhs/pystk.git
   cd pystk

   # install dependencies
   pip install -r requirements.txt

   # Run python setup script
   python setup.py install -- -DCMAKE_PREFIX_PATH=${TRILINOS_ROOT_DIR}

Building a development version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you are developing pySTK you should install the package in *development mode*
using the following commands instead of `setup.py install`

.. code-block:: bash

   # Build extensions
   python setup.py build_ext --inplace -- -DCMAKE_PREFIX_PATH=${TRILINOS_ROOT_DIR}
   # Install package in develoment mode
   pip install -e .

Once the package is installed in *editable mode* or (*development mode*), you
can execute the ``build_ext`` command after editing the Cython files and have the
latest version of the compiled extensions available within your environment.

.. note::

   If you have newer versions of CMake (3.15 or higher), then you can create an
   environment variable ``STK_ROOT`` and avoid passing additional arguments to
   ``build_ext``. For example,

   .. code-block:: bash

      export STK_ROOT=${TRILINOS_INSTALL_DIR}
      # Installation mode
      python setup.py install

      # Development mode
      python setup.py build_ext --inplace


Common build issues
~~~~~~~~~~~~~~~~~~~

If you are using `Anaconda Python <https://www.anaconda.com/>`_ (or Conda),
please make sure that you install `mpi4py
<https://mpi4py.readthedocs.io/en/stable/>`_ and `netcdf4-python
<https://unidata.github.io/netcdf4-python/netCDF4/index.html>`_ via source and
that the MPI you used to build these packages are consistent with the ones used
to build STK/Trilinos. Incompatibilities amongst MPI libraries used to build
STK/Trilinos and NetCDF4 can cause spurious memory errors and error messages
when attempting to open Exodus-II databases.

Basic Usage
-----------

This section provides a high-level overview of using the pySTK to interact with
STK data structures and Exodus-II databases. The STK API is exposed as closely
as possible through the python interface. For example, every STK class (e.g.,
``MetaData``, ``BulkData``, ``Part``, ``Selector``, etc.) has a python-wrapped
counterpart with the ``Stk`` prefix. For example, ``MetaData`` is exposed as
``StkMetaData`` within the python layer. Data getters/setters in `C++` are exposed
as python properties, while methods taking arguments are exposed as normal
python methods with more or less the same arguments. The following code snippets
show the C++ source and its corresponding python equivalent.

**STK usage in C++ code**

.. code-block:: c++

   int ndim=3;
   MetaData meta(ndim);
   // Get coordinates field
   auto& coords = meta.coordinate_field();
   // Get field name for coordinates
   auto& coords_name = meta.coordinate_field_name();
   // Get the part
   auto* part = meta.get_part("block_1");

   if (part == nullptr)
     std::cout << "Part does not exist" << std::endl;

**Corresponding Python equivalent**

.. code-block:: python

   ndim = 3
   meta = StkMetaData.create(ndim=ndim)
   coords = meta.coordinate_field
   coords_name = meta.coordinate_field_name
   part = meta.get_part("block_1")

   if part.is_null:
       print("Part does not exist")


The following python script shows a sample interaction using the pySTK library.
You can :download:`download the script <datafiles/basic_usage.py>`.

.. literalinclude:: datafiles/basic_usage.py
   :language: python
   :linenos:

pySTK API Reference
-------------------

StkMesh
~~~~~~~
.. autoclass:: stk.stk.stk_mesh.StkMesh
   :members:
   :exclude-members: declare_scalar_field_t

   .. attribute:: meta

      A :class:`~stk.api.mesh.meta.StkMetaData` instance

   .. attribute:: bulk

      A :class:`~stk.api.mesh.bulk.StkBulkData` instance

   .. attribute:: stkio

      A :class:`~stk.api.io.io.StkIoBroker` instance

StkMetaData
~~~~~~~~~~~
.. autoclass:: stk.api.mesh.meta.StkMetaData
   :members:

StkBulkData
~~~~~~~~~~~
.. autoclass:: stk.api.mesh.bulk.StkBulkData
   :members:

StkFieldBase
~~~~~~~~~~~~
.. autoclass:: stk.api.mesh.field.StkFieldBase
   :members:
   :exclude-members: get_t, bkt_view_t

   .. method:: get_t(entity)

      Get data from a field that is of a given type.

      .. code-block:: python

         # Get an int field data
         int_value = field.get_t[int](entity)

         # Explictly get double data
         dbl_val = field.get_t[cython.double](entity)

StkSelector
~~~~~~~~~~~
.. autoclass:: stk.api.mesh.selector.StkSelector
   :members:

StkPart
~~~~~~~
.. autoclass:: stk.api.mesh.part.StkPart
   :members:

StkBucket
~~~~~~~~~
.. autoclass:: stk.api.mesh.bucket.StkBucket
   :members:

StkTopology
~~~~~~~~~~~
.. autoclass:: stk.api.topology.topology.StkTopology
   :members:
   :undoc-members:

StkIoBroker
~~~~~~~~~~~
.. autoclass:: stk.api.io.io.StkIoBroker
   :members:

Parallel
~~~~~~~~
.. autoclass:: stk.api.util.parallel.Parallel
   :members:

Enumerated data types
~~~~~~~~~~~~~~~~~~~~~
.. autoclass:: stk.api.topology.topology.rank_t
   :members:
   :undoc-members:

.. autoclass:: stk.api.io.io.DatabasePurpose
   :members:
   :undoc-members:

.. autoclass:: stk.api.io.io.TimeMatchOption
   :members:
   :undoc-members:

.. autoclass:: stk.api.topology.topology.topology_t
   :members:
   :undoc-members:


Indices and tables
------------------

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
