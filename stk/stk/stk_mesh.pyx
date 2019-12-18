# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from ..api.io.io cimport DatabasePurpose, TimeMatchOption
from ..api.topology.topology cimport rank_t
from ..api.mesh.selector cimport StkSelector

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
                            TimeMatchOption tmo=TimeMatchOption.CLOSEST,
                            bool auto_decomp = True,
                            str auto_decomp_type="rcb"):
        """Open a file and load the meta data from the file

        This method combines various operations of the STK I/O for simplicity
            - Register an input mesh database
            - Assign bulk data with the STK I/O instance
            - Creates the metadata from the input mesh
            - Automatically declares all fields in the database as input fields

        Args:
            filename (str): Path to the Exodus database
            purpose: DatabasePurpose (READ_MESH, READ_RESTART)
            tmo: TimeMatchOption (CLOSEST, LINEAR_INTERPOLATION)
            auto_decomp (bool): Decompose mesh for parallel runs (default: True)
            auto_decomp_type (str): Decomposition type (default: rcb)
        """
        if auto_decomp and self.comm.size > 1:
            self.stkio.add_property("DECOMPOSITION_METHOD", auto_decomp_type)
        self.stkio.add_mesh_database(filename, purpose)
        self.stkio.set_bulk_data(self.bulk)
        self.stkio.create_input_mesh()
        self.stkio.add_all_mesh_fields_as_input_fields(tmo)

        coords = self.meta.coordinate_field
        coords.add_to_part(self.meta.universal_part,
                           self.meta.spatial_dimension)

    def populate_bulk_data(self, create_edges=False):
        """Commit MetaData and populate BulkData from the input database.

        If `create_edges is True`, then edge entities will be created before
        the field data is loaded.
        """
        if create_edges:
            self.stkio.populate_mesh()
            self.stkio.populate_field_data()
        else:
            self.stkio.populate_bulk_data()

    def iter_buckets(self, StkSelector sel, rank_t rank=rank_t.NODE_RANK):
        """Yield iterator for looping over buckets"""
        yield from self.bulk.iter_buckets(sel, rank)

    def iter_entities(self, StkSelector sel, rank_t rank=rank_t.NODE_RANK):
        """Yield iterator for looping over entities"""
        yield from self.bulk.iter_entities(sel, rank)
