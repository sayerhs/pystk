# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libc.stdint cimport uint64_t
from libcpp cimport bool

cdef extern from "stk_mesh/base/Entity.hpp" namespace "stk::mesh":
    cdef cppclass Entity:
        Entity()
        uint64_t local_offset() const
        bool is_local_offset_valid()

cdef class StkEntity:
    cdef Entity entity

    @staticmethod
    cdef wrap_instance(Entity entity)
