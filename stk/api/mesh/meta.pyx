# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cimport cython
from cython.operator cimport dereference as deref
from libcpp.cast cimport const_cast
from ..topology cimport topology

cdef class StkMetaData:
    """stk::mesh::MetaData"""
    def __cinit__(self):
        self.meta = NULL
        self.meta_owner = False

    def __dealloc__(self):
        if self.meta is not NULL and self.meta_owner is True:
            del self.meta

    def __eq__(self, StkMetaData other):
        return self.meta == other.meta

    @staticmethod
    cdef wrap_instance(MetaData* in_meta, bint owner=False):
        cdef StkMetaData meta_data = StkMetaData.__new__(StkMetaData)
        meta_data.meta = in_meta
        meta_data.meta_owner = owner
        return meta_data

    @staticmethod
    def create(int ndim = 3):
        """
        Create a new stk::mesh::MetaData instance

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
        return StkPart.wrap_instance(part)

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

    @property
    def coordinate_field(self):
        """Return the coordinate field"""
        cdef const FieldBase* fld = deref(self.meta).coordinate_field()
        return StkFieldBase.wrap_instance(const_cast[FieldBasePtr](fld))

    @coordinate_field.setter
    def coordinate_field(self, StkFieldBase field):
        """Set a new field as coordinate field"""
        cdef FieldBase* sfld = field.fld
        deref(self.meta).set_coordinate_field(sfld)

    def get_field(self, str name,
                  topology.rank_t rank=topology.rank_t.NODE_RANK,
                  must_exist=False):
        """Return a field of name on a requested entity rank"""
        cdef string fname = name.encode('UTF-8')
        cdef FieldBase* fld = deref(self.meta).get_field_base(rank, fname)
        if must_exist:
            assert fld != NULL, "Field does not exist: %s"%name
        return StkFieldBase.wrap_instance(fld)

    def declare_scalar_field(self, str name,
                             topology.rank_t rank=topology.rank_t.NODE_RANK,
                             unsigned number_of_states=1):
        """Declare a double scalar field"""
        cdef string fname = name.encode('UTF-8')
        cdef FieldBase* fld = NULL
        fld = <FieldBase*>&(deref(self.meta).declare_field[Field[double]](
            rank, fname, number_of_states))
        return StkFieldBase.wrap_instance(fld)

    def declare_vector_field(self, str name,
                             topology.rank_t rank=topology.rank_t.NODE_RANK,
                             unsigned number_of_states=1):
        """Declare a double vector field"""
        cdef string fname = name.encode('UTF-8')
        cdef FieldBase* fld = NULL
        fld = <FieldBase*>&(deref(self.meta).declare_field[Field[double, Cartesian]](
            rank, fname, number_of_states))
        return StkFieldBase.wrap_instance(fld)

    def declare_generic_field(self, str name,
                             topology.rank_t rank=topology.rank_t.NODE_RANK,
                             unsigned number_of_states=1):
        """Declare a double generic field"""
        cdef string fname = name.encode('UTF-8')
        cdef FieldBase* fld = NULL
        fld = <FieldBase*>&(deref(self.meta).declare_field[Field[double, SimpleArrayTag]](
            rank, fname, number_of_states))
        return StkFieldBase.wrap_instance(fld)

    def declare_scalar_field_t(self, str name,
                               topology.rank_t rank=topology.rank_t.NODE_RANK,
                               unsigned number_of_states=1,
                               cython.numeric data=0):
        """Declare a scalar field of a given type

        A scalar field is of type `Field<T>` and has rank 0.

        Example:
            density = meta.declare_scalar_field[double]("density")
            iblank  = meta.declare_scalar_field[int]("iblank")
        """
        cdef string fname = name.encode('UTF-8')
        cdef FieldBase* fld = NULL
        if cython.numeric is double:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[double]](
                rank, fname, number_of_states))
        elif cython.numeric is float:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[float]](
                rank, fname, number_of_states))
        elif cython.numeric is int:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[int]](
                rank, fname, number_of_states))
        elif cython.numeric is long:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[long]](
                rank, fname, number_of_states))

        if fld == NULL:
            raise RuntimeError("Invalid field type requested")
        return StkFieldBase.wrap_instance(fld)

    def declare_vector_field_t(self, str name,
                               topology.rank_t rank=topology.rank_t.NODE_RANK,
                               unsigned number_of_states=1,
                               cython.numeric data=0):
        """Declare a vector field

        A vector field is of type `Field<T, Cartesian>` of rank 1.

        Example:
            velocity = meta.declare_vector_field[double]("velocity", number_of_states=3)
        """
        cdef string fname = name.encode('UTF-8')
        cdef FieldBase* fld = NULL
        if cython.numeric is double:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[double, Cartesian]](
                rank, fname, number_of_states))
        elif cython.numeric is float:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[float, Cartesian]](
                rank, fname, number_of_states))
        elif cython.numeric is int:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[int, Cartesian]](
                rank, fname, number_of_states))
        elif cython.numeric is long:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[long, Cartesian]](
                rank, fname, number_of_states))

        if fld == NULL:
            raise RuntimeError("Invalid field type requested")
        return StkFieldBase.wrap_instance(fld)

    def declare_generic_field_t(self, str name,
                                topology.rank_t rank=topology.rank_t.NODE_RANK,
                                unsigned number_of_states=1,
                                cython.numeric data=0):
        """Declare a generic field of a given datatype

        A generic field is of type `Field<T, SimpleArrayTag>` with rank 1.

        Example:
            dudx = meta.declare_generic_field[double]("dudx")
        """
        cdef string fname = name.encode('UTF-8')
        cdef FieldBase* fld = NULL
        if cython.numeric is double:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[double, SimpleArrayTag]](
                rank, fname, number_of_states))
        elif cython.numeric is float:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[float, SimpleArrayTag]](
                rank, fname, number_of_states))
        elif cython.numeric is int:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[int, SimpleArrayTag]](
                rank, fname, number_of_states))
        elif cython.numeric is long:
            fld = <FieldBase*>&(deref(self.meta).declare_field[Field[long, SimpleArrayTag]](
                rank, fname, number_of_states))

        if fld == NULL:
            raise RuntimeError("Invalid field type requested")
        return StkFieldBase.wrap_instance(fld)
