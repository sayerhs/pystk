# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cimport cython
from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libcpp.vector cimport vector
from ..util.parallel cimport Parallel
from ..mesh.bulk cimport StkBulkData
from ..mesh.field cimport StkFieldBase

cdef class StkIoBroker:
    def __cinit__(self):
        self.stkio = NULL

    def __dealloc__(self):
        if (self.stkio is not NULL) and (self.stkio_owner is True):
            del self.stkio

    def __eq__(self, StkIoBroker other):
        return self.stkio == other.stkio

    @staticmethod
    cdef wrap_instance(StkMeshIoBroker* stkio, bint owner=False):
        cdef StkIoBroker pstkio = StkIoBroker.__new__(StkIoBroker)
        pstkio.stkio = stkio
        pstkio.stkio_owner = owner
        return pstkio

    @staticmethod
    def create(Parallel comm):
        """Create a StkIoBroker instance

        Args:
            comm (Parallel): Communicator instance

        Return:
            StkIoBroker: Newly created instance
        """
        cdef StkMeshIoBroker* stkio = new StkMeshIoBroker(comm.comm)
        return StkIoBroker.wrap_instance(stkio, owner=True)

    def set_bulk_data(self, StkBulkData bulk):
        """Associate the BulkData with this I/O broker.

        Args:
            bulk (StkBulkData): BulkData instance
        """
        deref(self.stkio).set_bulk_data(deref(bulk.bulk))

    def add_property(self, str name, str value):
        """Add an Ioss::Property to the broker

        Args:
            name (str): Name of the property
            value (str): Value of the property
        """
        cdef string cname = name.upper().encode('UTF-8')
        cdef string cvalue = value.encode('UTF-8')
        deref(self.stkio).property_add(Property(cname, cvalue))

    def add_mesh_database(self, str filename,
                          DatabasePurpose purpose=DatabasePurpose.READ_MESH):
        """Read an existing mesh database

        Args:
            filename (str): Name of the input database
            purpose (DatabasePurpose): READ_MESH, READ_RESTART etc.

        Return:
            size_t: File handle associated with the input mesh database
        """
        cdef string fname = filename.encode('UTF-8')
        cdef size_t fh = deref(self.stkio).add_mesh_database(fname, purpose)
        return fh

    def set_active_mesh(self, size_t fidx):
        """Set the active input mesh

        Args:
            fidx (size_t): File handle returned by add_mesh_database
        """
        cdef size_t fh1 = deref(self.stkio).set_active_mesh(fidx)
        return fh1

    def get_active_mesh(self):
        """Get the current active input mesh

        Return:
            size_t: File handle associated with the active mesh
        """
        return deref(self.stkio).get_active_mesh()

    def remove_mesh_database(self, size_t fidx):
        """Remove a previously registered mesh database from list.

        This method will close all open files related to that mesh database

        Args:
            fidx (size_t): File handle associated with the file to close
        """
        deref(self.stkio).remove_mesh_database(fidx)

    def create_input_mesh(self):
        """Read/Generate metadata for the mesh

        This method does not commit metadata.
        """
        deref(self.stkio).create_input_mesh()

    def populate_bulk_data(self):
        """Populate the bulk data for this mesh.

        This call is equivalent to calling `populate_mesh` followed by `populate_field_data`
        """
        deref(self.stkio).populate_bulk_data()

    def populate_mesh(self):
        """Populate the mesh data but not fields"""
        deref(self.stkio).populate_mesh()

    def populate_field_data(self):
        """Populate field data

        This method must be called after ``populate_mesh``
        """
        deref(self.stkio).populate_field_data()

    def add_all_mesh_fields_as_input_fields(self, TimeMatchOption tmo=TimeMatchOption.CLOSEST):
        """Load all existing fields in mesh database as input fields

        Args:
            tmo (TimeMatchOption): Option to interpolate for times
        """
        deref(self.stkio).add_all_mesh_fields_as_input_fields(tmo)

    def read_defined_input_fields_at_step(self, int step):
        """Read fields for a given timetep

        Args:
            step (int): Timestep

        Return:
            (double, list): Time read from database, list of missing fields
        """
        cdef vector[MeshField] missing
        cdef double time = deref(self.stkio).read_defined_input_fields_at_step(
            step, &missing)
        cdef size_t num_missing = missing.size()
        cdef list fnames = []
        for i in range(num_missing):
            fnames.append(missing[i].field().name())
        return (time, fnames)

    def read_defined_input_fields(self, double time):
        """Read fields for a requested time.

        The field depends on TimeMatchOption set for mesh fields

        Return:
            (double, list): The actual time for fields, list of missing fields
        """
        cdef vector[MeshField] missing
        cdef double time1 = deref(self.stkio).read_defined_input_fields(
            time, &missing)
        cdef size_t num_missing = missing.size()
        cdef list fnames = []
        for i in range(num_missing):
            fnames.append(missing[i].field().name())
        return (time1, fnames)

    def create_output_mesh(self, str filename,
                           DatabasePurpose purpose=DatabasePurpose.WRITE_RESULTS):
        """Create an Exodus database for writing results

        Args:
            filename (str): Name of the Exodus-II output database
            tmo (TimeMatchOption): ``WRITE_RESULTS``, ``WRITE_RESTART``

        Return:
            size_t: File handle for the newly created output database
        """
        cdef string fname = filename.encode('UTF-8')
        return deref(self.stkio).create_output_mesh(fname, purpose)

    def write_output_mesh(self, size_t fidx):
        """Write output mesh

        Args:
            fidx (size_t): File handle to output
        """
        deref(self.stkio).write_output_mesh(fidx)

    def add_field(self, size_t fidx, StkFieldBase field, str db_field_name=None):
        """Register a field for output to a given database.

        The user can provide a different name for the field in the output
        database by providing `db_field_name`. If this is None, then the field
        name is taken from the StkFieldBase instance.

        Args:
            fidx: Valid file handle from `create_output_mesh`
            field: Field instance to be output
            db_field_name: Custom name for field in the output database
        """
        cdef string dbname
        if db_field_name is None:
            deref(self.stkio).add_field(fidx, deref(field.fld))
        else:
            dbname = db_field_name.encode('UTF-8')
            deref(self.stkio).add_field(fidx, deref(field.fld), dbname)

    def begin_output_step(self, size_t fidx, double time):
        """Start a new output 'time' instance in database

        Args:
            fidx (size_t): Valid file handle from `create_output_mesh`
            time (double): Start a new timestep for output
        """
        deref(self.stkio).begin_output_step(fidx, time)

    def end_output_step(self, size_t fidx):
        """Mark end of output for current time

        Args:
            fidx (size_t): Valid file handle from `create_output_mesh`
        """
        deref(self.stkio).end_output_step(fidx)

    def write_defined_output_fields(self, size_t fidx):
        """Write registered fields for a given time

        The fields should have been previously added using
        :meth:`~stk.api.io.io.StkIoBroker.add_field`.

        Args:
            fidx (size_t): Valid file handle from `create_output_mesh`

        Return:
            int: Current output time step

        """
        return deref(self.stkio).write_defined_output_fields(fidx)

    def write_global(self, size_t file_index, str name, cython.numeric data):
        """Write a global parameter

        Args:
            file_index (size_t): File handle from a previous call
            name (str): Name of the global data variable
            data (double/int): Value of the global data
        """
        cdef string gname = name.encode('UTF-8')
        cdef double dbl_var
        cdef int int_var
        if cython.numeric is double:
            dbl_var = data
            deref(self.stkio).write_global(file_index, gname, dbl_var)
        elif cython.numeric is int:
            int_var = data
            deref(self.stkio).write_global(file_index, gname, int_var)

    @property
    def num_time_steps(self):
        """Number of timesteps in this database"""
        return deref(self.stkio).get_num_time_steps()

    @property
    def max_time(self):
        """Maximum time (double) available in the database"""
        return deref(self.stkio).get_max_time()

    @property
    def time_steps(self):
        """Return the list of timesteps available in this database"""
        cdef vector[double] tsteps = deref(self.stkio).get_time_steps()
        return [t for t in tsteps]

    def set_max_num_steps_before_overwrite(self, size_t file_index, int max_num_steps_in_file):
        """Maximum number of steps in database before overwriting"""
        deref(self.stkio).set_max_num_steps_before_overwrite(file_index, max_num_steps_in_file)

    def flush_output(self):
        """Flush output to disk"""
        deref(self.stkio).flush_output()

    def process_output_request(self, size_t file_index, double time):
        """Process output request to the database

        .. code-block:: python

           stkio.begin_output_step(file_index, time)
           stkio.write_defined_output_fields(file_index)
           stkio.end_output_step(file_index)

        Args:
            file_index (size_t): Open file handle
            time (double): Time to write
        """
        deref(self.stkio).process_output_request(file_index, time)
