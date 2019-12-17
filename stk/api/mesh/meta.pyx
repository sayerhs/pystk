# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref
from ..topology cimport topology

cdef class StkMetaData:
    """stk::mesh::MetaData"""
    def __cinit__(self):
        self.meta = NULL
        self.meta_owner = False

    def __dealloc__(self):
        if self.meta is not NULL and self.meta_owner is True:
            del self.meta

    @staticmethod
    cdef wrap_instance(MetaData* in_meta, bint owner=False):
        cdef StkMetaData meta_data = StkMetaData.__new__(StkMetaData)
        meta_data.meta = in_meta
        meta_data.meta_owner = owner
        return meta_data

    @staticmethod
    def create(int ndim = 3):
        """Create a new stk::mesh::MetaData instance

        Args:
            ndim (int): Spatial dimension of this STK mesh

        Return:
            StkMetaData: A wrapped instance of stk::mesh::MetaData
        """
        cdef MetaData* meta = new MetaData(ndim)
        return StkMetaData.wrap_instance(meta, owner=True)

    @property
    def has_mesh(self):
        """Does MetaData have a BulkData instance"""
        return deref(self.meta).has_mesh()

    @property
    def spatial_dimension(self):
        """Spatial dimension of this STK mesh"""
        assert(self.meta != NULL)
        return deref(self.meta).spatial_dimension()

    @property
    def universal_part(self):
        """Part that contains all entities"""
        assert(self.meta != NULL)
        return StkPart.wrap_instance(&deref(self.meta).universal_part())

    @property
    def locally_owned_part(self):
        """Part containing entities owned by the current MPI rank"""
        assert(self.meta != NULL)
        return StkPart.wrap_instance(&deref(self.meta).locally_owned_part())

    @property
    def globally_shared_part(self):
        """Part containing shared entities with other MPI ranks"""
        assert(self.meta != NULL)
        return StkPart.wrap_instance(&deref(self.meta).globally_shared_part())

    @property
    def aura_part(self):
        """Aura part"""
        assert(self.meta != NULL)
        return StkPart.wrap_instance(&deref(self.meta).aura_part())

    def get_parts(self, io_parts_only=True):
        """Get all parts registered in STK Mesh"""
        assert(self.meta != NULL)
        pparts = []
        cdef const PartVector* part_vec = &deref(self.meta).get_parts()
        cdef size_t nparts = deref(part_vec).size()
        cdef Part* pp
        cdef long pid
        if io_parts_only:
            for i in range(nparts):
                pp = deref(part_vec)[i]
                pid = deref(pp).part_id()
                if pid > 0:
                    pparts.append(StkPart.wrap_instance(pp))
        else:
            for i in range(nparts):
                pparts.append(StkPart.wrap_instance(deref(part_vec)[i]))
        return pparts

    def get_part(self, part_name, must_exist=False):
        """Return a part instance"""
        cdef string pname = part_name.encode('UTF-8')
        cdef Part* part = deref(self.meta).get_part(pname)
        if must_exist:
            assert(part != NULL)
        cdef StkPart spart = StkPart.__new__(StkPart)
        spart.part = part
        return spart

    def declare_part(self, part_name, topology.rank_t rank=topology.rank_t.NODE_RANK):
        """Declare a new part

        Args:
            part_name (str): Name of the part
            rank (rank_t): Rank of the part (default: NODE_RANK)
        """
        cdef string pname = part_name.encode('UTF-8')
        cdef Part* part = &(deref(self.meta).declare_part(pname, rank))
        return StkPart.wrap_instance(part)

    def initialize(self, int ndim=3):
        """Initialize the STK mesh"""
        assert(self.meta != NULL)
        deref(self.meta).initialize(ndim)

    def commit(self):
        """Commit the metadata"""
        deref(self.meta).commit()

    @property
    def is_initialized(self):
        """Flag indicating whether the MetaData has been initialized"""
        return deref(self.meta).is_initialized()

    @property
    def is_committed(self):
        """Is the metadata committed?"""
        return deref(self.meta).is_commit()

    @property
    def side_rank(self):
        """Rank for the sidesets"""
        return deref(self.meta).side_rank()

    @property
    def coordinate_field_name(self):
        """Return the name of the coordinates field"""
        return deref(self.meta).coordinate_field_name().decode('UTF-8')

    @coordinate_field_name.setter
    def coordinate_field_name(self, str coord_name):
        cdef string cname = coord_name.encode('UTF-8')
        deref(self.meta).set_coordinate_field_name(cname)
