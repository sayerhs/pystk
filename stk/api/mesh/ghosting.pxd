# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp.string cimport string

cdef extern from "stk_mesh/base/Ghosting.hpp" namespace "stk::mesh":
    cdef cppclass Ghosting:
        const string& name() const
        unsigned ordinal() const


cdef class StkGhosting:
    cdef Ghosting* ghosting

    @staticmethod
    cdef wrap_instance(Ghosting* ghosting)

    @staticmethod
    cdef wrap_reference(Ghosting& ghosting)
