# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libc.stdint cimport int64_t
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from ..topology.topology cimport topology as topo_cls
from .selector cimport *

cdef extern from "stk_mesh/base/Part.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Part:
        string& name() const
        topo_cls topology() const
        int64_t id() const

        bool contains(const Part&) const
        const PartVector& supersets() const
        const PartVector& subsets() const

cdef extern from "stk_io/IossBridge.hpp" namespace "stk::io":
    bool is_part_io_part(const Part& part)
    void put_io_part_attribute(Part& part)
    void remove_io_part_attribute(Part& part)
    bool has_io_part_attribute(Part& part)

cdef class StkPart:
    cdef Part* part

    @staticmethod
    cdef wrap_instance(Part* part)

    @staticmethod
    cdef wrap_reference(Part& part)
