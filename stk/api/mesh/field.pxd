# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True
# cython: infer_types = True

cimport cython
from libcpp cimport bool
from libcpp.string cimport string
cimport numpy as np
from .stk_mesh_fwd cimport *
from .bucket cimport *
from .part cimport *
from .meta cimport *

cdef extern from "stk_mesh/base/Entity.hpp" namespace "stk::mesh":
    cdef cppclass Entity:
        Entity()

cdef extern from "stk_mesh/base/FieldState.hpp" namespace "stk::mesh":
    cpdef enum FieldState:
        StateNone, StateNew, StateNP1,
        StateOld, StateN,
        StateNM1, StateNM2, StateNM3, StateNM4,
        StateInvalid

cdef extern from "stk_mesh/base/FieldTraits.hpp" namespace "stk::mesh":
    cdef cppclass FieldTraits[T]

cdef extern from "stk_mesh/base/FieldBase.hpp" namespace "stk::mesh":
    cdef cppclass FieldBase:
        MetaData& mesh_meta_data() const
        unsigned mesh_meta_data_ordinal() const
        const string& name() const
        bool type_is[T]() const
        unsigned number_of_states() const
        FieldState state() const
        unsigned field_array_rank() const
        EntityRank entity_rank() const
        unsigned max_size() const
        FieldBase* field_state(FieldState state) const
        bool is_state_valid(FieldState state) const
        BulkData& get_mesh() const
        bool defined_on(const Part& part) const

cdef extern from "stk_mesh/base/Field.hpp" namespace "stk::mesh":
    cdef cppclass Field[Scalar, Tag1=*, Tag2=*, Tag3=*, Tag4=*, Tag5=*, Tag6=*, Tag7=*]:
        ctypedef void Tag1
        ctypedef void Tag2
        ctypedef void Tag3
        ctypedef void Tag4
        ctypedef void Tag5
        ctypedef void Tag6
        ctypedef void Tag7

        Field& field_of_state(FieldState input_state) const

cdef extern from "stk_mesh/base/FieldBase.hpp" namespace "stk::mesh":
    void* field_data[FieldBase](const FieldBase& f, Entity e)
    void* field_data[FieldBase](const FieldBase& f, const Bucket& b)

    unsigned field_scalars_per_entity(const FieldBase& f, Entity e)
    unsigned field_scalars_per_entity(const FieldBase& f, const Bucket& b)


ctypedef FieldBase* FieldBasePtr

cdef class StkFieldBase:
    cdef FieldBase* fld

    @staticmethod
    cdef wrap_instance(FieldBase* fld)
