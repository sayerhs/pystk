# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from libcpp cimport bool
from ..topology.topology cimport topology as topo_cls
from .stk_mesh_fwd cimport Entity, EntityRank

cdef extern from "stk_mesh/base/Bucket.hpp" namespace "stk::mesh" nogil:
    cdef cppclass Bucket:
        topo_cls topology() const
        bool owned() const
        bool shared() const
        bool in_aura() const
        size_t size() const
        Entity operator[](size_t i) const
        unsigned bucket_id() const
        EntityRank entity_rank() const

cdef class StkBucket:
    cdef Bucket* bkt

    @staticmethod
    cdef wrap_instance(Bucket* bkt)
