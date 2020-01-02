# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True
# cython: infer_types = True

from cython.operator cimport dereference as deref
from libc.stdint cimport int64_t, uint64_t
from libcpp.string cimport string
from libcpp.cast cimport dynamic_cast
from libcpp.vector cimport vector
from ..topology cimport topology as T
from .entity cimport StkEntity
from .bucket cimport StkBucket
from .meta cimport StkMetaData, put_field_on_mesh
from .bulk cimport StkBulkData
from .part cimport StkPart
from .selector cimport StkSelector

cimport numpy as np
import numpy as np

cdef class StkFieldBase:
    """stk::mesh::FieldBase

    .. code-block:: python

       # Declaring a field (keyword arguments are optional, defaults shown)
       pressure = meta.declare_scalar_field(
       "pressure", rank=rank_t.NODE_RANK, number_of_states=1)
       # Overriding defaults
       velocity = meta.declare_vector_field("velocity", rank_t.NODE_RANK, 3)

       # Getting a field (keyword arguments are optional, defaults shown)
       pressure1 = meta.get_field("pressure", rank=rank_t.NODE_RANK, must_exist=False)

       ### Accessing field data
       #
       # For an entity
       pres = pressure.get(entity)
       vel = velocity.get(entity)
       old = pres[0]
       pres[0] = 20.0
       vel[0] = 10.0
       vel[1] = 5.0
       vel[2] = 0.0

       # For buckets
       pres_bkt = pressure.bkt_view(bkt)
       tmp = pres_bkt[-1]
       pres_bkt[-1] = 20.0

       vel_bkt = velocity.bkt_view(bkt)
       vel_bkt[-1, 2] = 0.0
    """

    def __cinit__(self):
        self.fld = NULL

    def __eq__(self, StkFieldBase other):
        return self.fld == other.fld

    @staticmethod
    cdef wrap_instance(FieldBase* fld):
        cdef StkFieldBase sfld = StkFieldBase.__new__(StkFieldBase)
        sfld.fld = fld
        return sfld

    @property
    def meta_data(self):
        """``stk::mesh::MetaData`` associated with this field"""
        return StkMetaData.wrap_instance(&deref(self.fld).mesh_meta_data())

    @property
    def bulk_data(self):
        """``stk::mesh::BulkData`` associated with this field"""
        return StkBulkData.wrap_instance(&deref(self.fld).get_mesh())

    @property
    def name(self):
        """Name of the field"""
        return deref(self.fld).name().decode('UTF-8')

    @property
    def number_of_states(self):
        """Number of states available for this field"""
        return deref(self.fld).number_of_states()

    @property
    def field_array_rank(self):
        """Array dimensionality"""
        return deref(self.fld).field_array_rank()

    @property
    def entity_rank(self):
        """Entity rank on which the field is defined"""
        return deref(self.fld).entity_rank()

    @property
    def field_ordinal(self):
        """Unique ordinal to identify this field"""
        return deref(self.fld).mesh_meta_data_ordinal()

    @property
    def is_null(self):
        """Does the field exist"""
        return (self.fld == NULL)

    def is_state_valid(self, FieldState state):
        """Check if the requested state is valid

        Args:
            state (FieldState): State parameter

        Return:
            bool: True if the field has the requested state
        """
        return deref(self.fld).is_state_valid(state)

    def field_state(self, FieldState state):
        """Return the field at state

        Args:
            state (FieldState): State parameter

        Return:
            StkFieldBase: Field instance corresponding to the state requested
        """
        cdef FieldBase* fld = deref(self.fld).field_state(state)
        assert (fld != NULL), "Invalid field state encountered"
        return StkFieldBase.wrap_instance(fld)

    def get(self, StkEntity entity):
        """Get the data for a given entity

        Returns a 1-D numpy array containing 1 element for scalar, 3 for vector
        and so on. For scalars data types, returning a numpy array of shape
        ``(1,)`` allows modification of field data from the python. For
        example,

        .. code-block:: python

           pressure = pressure_field.get(entity)
           pressure[0] = 10.0

        Args:
            entity (StkEntity): Entity instance

        Return:
            np.ndarray: View of the entity data

        """
        cdef Entity sentity = entity.entity
        cdef void* ptr = field_data(deref(self.fld), sentity)
        cdef unsigned ncomp = field_scalars_per_entity(deref(self.fld), sentity)
        return np.asarray(<double[:ncomp]>ptr)

    def bkt_view(self, StkBucket bkt):
        """Get the data view for a bucket

        For scalar fields, this method returns a 1-D array with ``bkt.size``
        elements. For vector fields, it returns a 2-D array of shape
        ``(bkt.size, num_components)``.

        Args:
            bkt (StkBucket): Bucket instance

        Return:
            np.ndarray: View of the bucket data as a NumPy array
        """
        cdef Bucket* sbkt = bkt.bkt
        cdef void* ptr = field_data(deref(self.fld), deref(sbkt))
        cdef unsigned ncomp = field_scalars_per_entity(deref(self.fld), deref(sbkt))
        if ncomp == 1:
            return np.asarray(<double[:bkt.size]>ptr)
        else:
            return np.asarray(<double[:bkt.size, :ncomp]>ptr)

    def get_t(self, StkEntity entity, cython.numeric dtype=0):
        """Get the data for a given entity"""
        cdef Entity sentity = entity.entity
        cdef void* ptr = field_data(deref(self.fld), sentity)
        cdef unsigned ncomp = field_scalars_per_entity(deref(self.fld), sentity)
        return np.asarray(<cython.numeric[:ncomp]>ptr)

    def bkt_view_t(self, StkBucket bkt, cython.numeric dtype=0):
        """Get the data view for a bucket"""
        cdef Bucket* sbkt = bkt.bkt
        cdef void* ptr = field_data(deref(self.fld), deref(sbkt))
        cdef unsigned ncomp = field_scalars_per_entity(deref(self.fld), deref(sbkt))
        if ncomp == 1:
            return np.asarray(<cython.numeric[:bkt.size]>ptr)
        else:
            return np.asarray(<cython.numeric[:bkt.size, :ncomp]>ptr)

    def add_to_part(self, StkPart part, int num_components=1, double[:] init_value=None):
        """Register field to a given part

        Args:
            part (StkPart): Part instance
            num_components (int): Number of components
            init_value (np.ndarray): Array of initialization values for the field on part
        """
        cdef Part* spart = part.part
        cdef FieldBase* sfield = self.fld
        cdef double* init_ptr = NULL
        if init_value is not None:
            assert num_components == init_value.shape[0], "Size mismatch in initial value"
            init_ptr = &init_value[0]
        if num_components == 1:
            put_field_on_mesh(deref(sfield), deref(spart), init_ptr)
        else:
            put_field_on_mesh(deref(sfield), deref(spart), num_components, init_ptr)

    def add_to_selected(self, StkSelector sel,
                        int num_components=1, double[:] init_value=None):
        """Register field to parts matching the given selector

        Args:
            sel (StkSelector): Selector for parts where this field is added
            num_components (int): Number of components
            init_value (np.ndarray): Array of initialization values for the field on part
        """
        cdef Selector ssel = sel.sel
        cdef FieldBase* sfield = self.fld
        cdef double* init_ptr = NULL
        if init_value is not None:
            assert num_components == init_value.shape[0], "Size mismatch in initial value"
            init_ptr = &init_value[0]
        if num_components == 1:
            put_field_on_mesh(deref(sfield), ssel, init_ptr)
        else:
            put_field_on_mesh(deref(sfield), ssel, num_components, init_ptr)

    def __repr__(self):
        if self.fld != NULL:
            return "<%s: %s>"%(self.__class__.__name__, self.name)
        else:
            return "<%s: %s>"%(self.__class__.name__, "INVALID_FIELD")
