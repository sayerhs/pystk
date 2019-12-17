# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libc.stdint cimport int64_t
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from ..topology.topology cimport topology as topo_cls

cdef extern from "stk_mesh/base/Types.hpp" namespace "stk::mesh" nogil:
    ctypedef vector[Part*] PartVector

cdef extern from "stk_mesh/base/Part.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Part:
        string& name() const
        topo_cls topology() const
        int64_t part_id "id" () const

        bool contains(const Part&) const
        const PartVector& supersets() const
        const PartVector& subsets() const

cdef class StkPart:
    cdef Part* part

    @staticmethod
    cdef wrap_instance(Part* part)
