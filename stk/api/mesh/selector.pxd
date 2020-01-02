# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from .stk_mesh_fwd cimport *
from .part cimport Part
from .field cimport FieldBase

cdef extern from "stk_mesh/base/Selector.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Selector:
        Selector()
        Selector(const Part& part)
        Selector(const FieldBase& field)

        bool operator==(const Selector& rhs) const
        bool operator!=(const Selector& rhs) const
        Selector operator!() const
        Selector& complement()

        bool is_empty(EntityRank) const

    Selector operator&(const Part& A, const Part& B)
    Selector operator&(const Part& A, const Selector& B)
    Selector operator&(const Selector& A, const Part& B)
    Selector operator&(const Selector& A, const Selector& B)
    Selector operator|(const Part& A, const Part& B)
    Selector operator|(const Part& A, const Selector& B)
    Selector operator|(const Selector& A, const Part& B)
    Selector operator|(const Selector& A, const Selector& B)
    Selector operator!(const Part& A)

    Selector selectUnion[VecType](const VecType& part_vec)
    Selector selectIntersection(const PartVector& part_vec)
    Selector selectIntersection(const ConstPartVector& part_vec)
    Selector selectField(const FieldBase& field)

cdef class StkSelector:
    cdef Selector sel
