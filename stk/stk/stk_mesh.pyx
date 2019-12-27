# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from libcpp cimport bool
from ..api.io.io cimport DatabasePurpose, TimeMatchOption
from ..api.topology.topology cimport rank_t
from ..api.mesh.selector cimport StkSelector
from ..api.mesh.misc cimport *

cdef class StkMesh:

    def __init__(self, Parallel comm, int ndim=3):
        """Create a new StkMesh instance

        Args:
            comm: Communicator object
            ndim: Dimensionality of the mesh
        """
        self.comm = comm
        self.meta = StkMetaData.create(ndim=ndim)
        self.bulk = StkBulkData.create(self.meta, self.comm)
        self.stkio = StkIoBroker.create(self.comm)

    def read_mesh_meta_data(self, str filename,
                            DatabasePurpose purpose=DatabasePurpose.READ_MESH,
                            bool auto_decomp = True,
                            str auto_decomp_type="rcb",
                            bool auto_declare_fields = True,
                            TimeMatchOption tmo=TimeMatchOption.CLOSEST):
        """Open a file and load the meta data from the file

        This method combines various operations of the
        :class:`~stk.api.io.io.StkIoBroker` for simplicity

            - Register an input mesh database
            - Assign bulk data with the STK I/O instance
            - Creates the metadata from the input mesh
            - Automatically declares all fields in the database as input fields

        Args:
            filename (str): Path to the Exodus database
            purpose (DatabasePurpose): READ_MESH, READ_RESTART
            auto_decomp (bool): Decompose mesh for parallel runs (default: True)
            auto_decomp_type (str): Decomposition type (default: rcb)
            auto_declare_fields (bool): If True, declare fields found in file
            tmo (TimeMatchOption): CLOSEST, LINEAR_INTERPOLATION

        """
        if auto_decomp and self.comm.size > 1:
            self.stkio.add_property("DECOMPOSITION_METHOD", auto_decomp_type)
        self.stkio.add_mesh_database(filename, purpose)
        self.stkio.set_bulk_data(self.bulk)
        self.stkio.create_input_mesh()
        if auto_declare_fields:
            self.stkio.add_all_mesh_fields_as_input_fields(tmo)

        coords = self.meta.coordinate_field
        coords.add_to_part(self.meta.universal_part,
                           self.meta.spatial_dimension)

    cdef create_edges_helper(self):
        create_edges(deref(self.bulk.bulk))

    def populate_bulk_data(self, create_edges=False, auto_load_fields=False):
        """Commit MetaData and populate BulkData from the input database.

        If ``create_edges is True``, then edge entities will be created before
        the field data is loaded.

        if ``auto_load_fields is True`` then this method will automatically
        load the fields from the database for the latest time found in the
        database.
        """
        cdef BulkData* bulk = NULL
        if create_edges:
            self.stkio.populate_mesh()
            self.create_edges_helper()
            self.stkio.populate_field_data()
        else:
            self.stkio.populate_bulk_data()

        if auto_load_fields:
            nsteps = self.stkio.num_time_steps
            # Do nothing if there are no timesteps
            if nsteps == 0:
                return (None, [])
            time_available = self.stkio.time_steps
            ftime, missing = self.stkio.read_defined_input_fields_at_time(time_available[-1])
            return (ftime, missing)

    def iter_buckets(self, StkSelector sel, rank_t rank=rank_t.NODE_RANK):
        """Yield iterator for looping over buckets"""
        yield from self.bulk.iter_buckets(sel, rank)

    def iter_entities(self, StkSelector sel, rank_t rank=rank_t.NODE_RANK):
        """Yield iterator for looping over entities"""
        yield from self.bulk.iter_entities(sel, rank)

    def set_io_properties(self, **kwargs):
        """Set IOSS properties for Exodus I/O

        One of more key-value pairs
        """
        for key, value in kwargs.items():
            self.stkio.add_property(key, value)

    def set_auto_join(self, output=True, restart=True):
        """Turn auto-join on/off for output/restart

        Args:
            output (bool): If True, auto-join output files
            restart (bool): If True, auto-join restart files
        """
        out_opt = "YES" if output else "NO"
        rst_opt = "YES" if restart else "NO"
        self.stkio.add_property("COMPSOSE_RESULTS", out_opt)
        self.stkio.add_property("COMPSOSE_RESTART", rst_opt)
