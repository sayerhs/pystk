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

cdef dict field_state_map = dict(
    StateNew = StateNew,
    StateNP1 = StateNP1,
    StateNone = StateNone,
    StateN = StateN,
    StateOld = StateOld,
    StateNM1 = StateNM1,
    StateNM2 = StateNM2,
    StateNM3 = StateNM3,
    StateNM4 = StateNM4
)


cdef class StkFieldBase:

    def __cinit__(self):
        self.fld = NULL

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

    def __repr__(self):
        return "<%s: %s>"%(self.__class__.__name__, self.name)
