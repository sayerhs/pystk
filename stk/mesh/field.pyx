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

cdef field_data_type(FieldBase* fld):
    """Get the field datatype"""
    if deref(fld).type_is[double]():
        return np.double
    elif deref(fld).type_is[float]():
        return np.float
    elif deref(fld).type_is[int]():
        return np.int
    elif deref(fld).type_is[long]():
        return np.long
    elif deref(fld).type_is[int64_t]():
        return np.int64
    elif deref(fld).type_is[uint64_t]():
        return np.uint64
    else:
        return np.void


cdef class StkFieldBase:

    def __cinit__(self):
        self.fld = NULL
        self.dtype = np.void

    @staticmethod
    cdef wrap_instance(FieldBase* fld, np.dtype dtype=None):
        cdef StkFieldBase sfld = StkFieldBase.__new__(StkFieldBase)
        cdef np.dtype dtype1 = np.void
        if (dtype is None) and (fld != NULL):
            dtype1 = field_data_type(fld)
        sfld.fld = fld
        sfld.dtype = dtype
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

    def is_state_valid(self, str state):
        """Check if the requested state is valid"""
        if state not in field_state_map:
            raise ValueError("Invalid state requested")
        cdef FieldState fstate = field_state_map[state]
        return deref(self.fld).is_state_valid(fstate)


    def field_state(self, str state):
        """Return the field at state

        Valid values for state:
            StateNone, StateNew, StateOld
            StateNP1, StateN, StateNM1, StateNM2, StateNM3, StateNM4
        """
        if state not in field_state_map:
            raise ValueError("Invalid state requested")
        cdef FieldState fstate = field_state_map[state]
        cdef FieldBase* fld = deref(self.fld).field_state(fstate)
        assert (fld != NULL), "Invalid field state encountered"
        return StkFieldBase.wrap_instance(fld, self.dtype)

    def __repr__(self):
        return "<%s: %s>"%(self.__class__.__name__, self.name)
