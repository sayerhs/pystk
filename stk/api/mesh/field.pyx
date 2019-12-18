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

cimport numpy as np
import numpy as np

cdef class StkFieldBase:

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
        """stk::mesh::MetaData associated with this field"""
        return StkMetaData.wrap_instance(&deref(self.fld).mesh_meta_data())

    @property
    def bulk_data(self):
        """stk::mesh::BulkData associated with this field"""
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
    def field_ordinal(self):
        """Unique ordinal to identify this field"""
        return deref(self.fld).mesh_meta_data_ordinal()

    def is_state_valid(self, FieldState state):
        """Check if the requested state is valid"""
        return deref(self.fld).is_state_valid(state)

    def field_state(self, FieldState state):
        """Return the field at state

        Valid values for state:
            StateNone, StateNew, StateOld
            StateNP1, StateN, StateNM1, StateNM2, StateNM3, StateNM4
        """
        cdef FieldBase* fld = deref(self.fld).field_state(state)
        assert (fld != NULL), "Invalid field state encountered"
        return StkFieldBase.wrap_instance(fld)

    def get(self, StkEntity entity):
        """Get the data for a given entity"""
        cdef Entity sentity = entity.entity
        cdef void* ptr = field_data(deref(self.fld), sentity)
        cdef unsigned ncomp = field_scalars_per_entity(deref(self.fld), sentity)
        return np.asarray(<double[:ncomp]>ptr)

    def bkt_view(self, StkBucket bkt):
        """Get the data view for a bucket"""
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
        """Register field to a given part"""
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

    def __repr__(self):
        if self.fld != NULL:
            return "<%s: %s>"%(self.__class__.__name__, self.name)
        else:
            return "<%s: %s>"%(self.__class__.name__, "INVALID_FIELD")
